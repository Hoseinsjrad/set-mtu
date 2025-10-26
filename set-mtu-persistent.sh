#!/usr/bin/env bash
# ============================================
# set-mtu-persistent.sh
# Persistent MTU setter for Ubuntu servers
# Supports: Netplan, NetworkManager, systemd fallback
# Usage:
#   sudo ./set-mtu-persistent.sh          # interactive
#   sudo ./set-mtu-persistent.sh --iface eth0 --mtu 9000  # CLI
# ============================================

set -euo pipefail

# -----------------------------
# Functions
# -----------------------------
err() { echo -e "\e[1;31m[ERROR]\e[0m $*" >&2; exit 1; }
info() { echo -e "\e[1;34m[INFO]\e[0m $*"; }

# Check root
if [ "$EUID" -ne 0 ]; then
    err "Please run this script with sudo."
fi

# Parse CLI arguments
INTERFACE=""
MTU=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --iface) INTERFACE="$2"; shift 2 ;;
    --mtu)   MTU="$2"; shift 2 ;;
    -h|--help) 
      echo "Usage: sudo $0 [--iface <iface>] [--mtu <value>]"
      exit 0 ;;
    *) err "Unknown argument: $1" ;;
  esac
done

# Detect default interface if not provided
detect_default_interface() {
  ip route | grep default | awk '{print $5}' | head -n 1
}

if [ -z "$INTERFACE" ]; then
    INTERFACE=$(detect_default_interface)
fi

if [ -z "$INTERFACE" ]; then
    err "Could not detect default network interface. Use --iface argument."
fi
info "Interface: $INTERFACE"

# Interactive MTU if not provided
if [ -z "$MTU" ]; then
    read -rp "Enter desired MTU (68-9000): " MTU
fi

# Validate MTU
if ! [[ "$MTU" =~ ^[0-9]+$ ]] || [ "$MTU" -lt 68 ] || [ "$MTU" -gt 9000 ]; then
    err "Invalid MTU value. Must be a number between 68 and 9000."
fi

# Backup directory
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/etc/set-mtu-backups-${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

# -----------------------------
# Apply MTU immediately
# -----------------------------
ip link set dev "$INTERFACE" mtu "$MTU"
info "Immediate MTU change applied."

# -----------------------------
# Detect NetworkManager
# -----------------------------
NM_ACTIVE="no"
if command -v nmcli &> /dev/null && systemctl is-active --quiet NetworkManager; then
    NM_ACTIVE="yes"
fi

# -----------------------------
# NetworkManager method
# -----------------------------
if [ "$NM_ACTIVE" = "yes" ]; then
    info "NetworkManager detected. Applying MTU via nmcli..."
    CONN=$(nmcli -t -f NAME,DEVICE connection show | awk -F: -v dev="$INTERFACE" '$2==dev{print $1; exit}')
    if [ -z "$CONN" ]; then
        CONN="set-mtu-$INTERFACE-$TIMESTAMP"
        info "No existing connection found. Creating $CONN"
        nmcli connection add type ethernet ifname "$INTERFACE" con-name "$CONN"
    fi
    mkdir -p "$BACKUP_DIR/nmcli"
    nmcli connection export "$CONN" "$BACKUP_DIR/nmcli/${CONN}.nmconnection" >/dev/null 2>&1 || true
    nmcli connection modify "$CONN" 802-3-ethernet.mtu "$MTU"
    nmcli connection down "$CONN" >/dev/null 2>&1 || true
    nmcli connection up "$CONN" >/dev/null 2>&1 || true
    info "MTU set via NetworkManager. Persistent after reboot."
    exit 0
fi

# -----------------------------
# Netplan method
# -----------------------------
if compgen -G "/etc/netplan/*.yaml" >/dev/null 2>&1; then
    info "Netplan detected. Creating persistent configuration..."
    NETPLAN_DIR="/etc/netplan"
    NETPLAN_FILE=$(find $NETPLAN_DIR -name "*.yaml" | head -n1)
    if [ -z "$NETPLAN_FILE" ]; then
        NETPLAN_FILE="$NETPLAN_DIR/01-netcfg.yaml"
        cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: true
EOF
    fi
    cp "$NETPLAN_FILE" "$BACKUP_DIR/netplan_$(basename $NETPLAN_FILE).bak"
    
    # Apply MTU safely
    if command -v yq &> /dev/null; then
        yq eval ".network.ethernets.$INTERFACE.mtu = $MTU" -i "$NETPLAN_FILE"
    else
        if grep -q "$INTERFACE:" "$NETPLAN_FILE"; then
            sed -i "/$INTERFACE:/a \      mtu: $MTU" "$NETPLAN_FILE"
        else
            sed -i "/ethernets:/a \    $INTERFACE:\n      dhcp4: true\n      mtu: $MTU" "$NETPLAN_FILE"
        fi
    fi
    netplan apply
    info "MTU set via Netplan. Persistent after reboot."
    exit 0
fi

# -----------------------------
# Fallback systemd service
# -----------------------------
info "Using systemd service fallback..."
SERVICE_FILE="/etc/systemd/system/set-mtu-${INTERFACE}.service"
mkdir -p "$BACKUP_DIR/systemd"
[ -f "$SERVICE_FILE" ] && cp "$SERVICE_FILE" "$BACKUP_DIR/systemd/"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Set MTU ${MTU} on ${INTERFACE}
After=network-pre.target
Before=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip link set dev ${INTERFACE} mtu ${MTU}
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now "set-mtu-${INTERFACE}.service"
info "Systemd service created and enabled. MTU persistent after reboot."

# -----------------------------
# Final message
# -----------------------------
info "All done. Backup directory: $BACKUP_DIR"
info "Verify MTU: ip link show $INTERFACE"
exit 0
