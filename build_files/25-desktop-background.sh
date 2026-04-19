#!/bin/bash

set -ouex pipefail

# Create a systemd service that applies desktop background configuration from
# /usr/share/sikker-selvbetjening/desktop.conf (provided by overlay OS layer).
# The config file specifies an image file (background_image_file) with path
# relative to /usr/share/sikker-selvbetjening/assets/.

# Create the systemd service unit
mkdir -p /usr/lib/systemd/system/
cat > /usr/lib/systemd/system/sikker-selvbetjening-desktop-bg.service << 'EOF'
[Unit]
Description=Apply desktop background from sikker-selvbetjening overlay configuration
After=network-online.target dbus.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/libexec/sikker-selvbetjening-apply-background.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create the helper script that applies the background at boot time
mkdir -p /usr/libexec/
cat > /usr/libexec/sikker-selvbetjening-apply-background.sh << 'EOF'
#!/bin/bash
# Apply desktop background from overlay-provided configuration at runtime

# Wait for dconf to be ready
sleep 2

OVERLAY_CONF="/usr/share/sikker-selvbetjening/desktop.conf"
OVERLAY_ASSETS_DIR="/usr/share/sikker-selvbetjening/assets"
SYSTEM_BG_DIR="/usr/share/backgrounds"

# Only proceed if the overlay config exists
if [[ ! -f "$OVERLAY_CONF" ]]; then
	exit 0
fi

# Source the config file to read background_image_file variable
background_image=$(bash -c "source '$OVERLAY_CONF' 2>/dev/null && echo \"\$background_image_file\"" || echo "")

if [[ -z "$background_image" ]]; then
	exit 0
fi

# Build the full path to the image file (relative to overlay assets dir)
image_path="$OVERLAY_ASSETS_DIR/$background_image"

if [[ ! -f "$image_path" ]]; then
	echo "Warning: Background image not found at $image_path"
	exit 0
fi

# Copy image to system backgrounds directory
mkdir -p "$SYSTEM_BG_DIR"
cp "$image_path" "$SYSTEM_BG_DIR/"

# Get the filename for the dconf setting
image_filename=$(basename "$background_image")
system_image_path="$SYSTEM_BG_DIR/$image_filename"

# Write the dconf setting for the desktop background
mkdir -p /etc/dconf/db/local.d/
cat > /etc/dconf/db/local.d/03-desktop-background << DCONF
# Desktop background image (from overlay)
[org/gnome/desktop/background]
picture-uri='file://${system_image_path}'
picture-uri-dark='file://${system_image_path}'
picture-options='zoom'
primary-color='#000000'
secondary-color='#000000'
DCONF

# Update dconf database to apply the setting
dconf update
EOF

chmod +x /usr/libexec/sikker-selvbetjening-apply-background.sh

# Enable the runtime background service to run at boot
systemctl enable sikker-selvbetjening-desktop-bg.service
