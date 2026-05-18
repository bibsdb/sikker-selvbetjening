#!/bin/bash

# Configuration (Time in milliseconds)
# 2 minutes = 120000 ms
IDLE_THRESHOLD=120000 
PROMPT_TIMEOUT=30

# State Tracker: Starts as false so we don't reboot an empty computer
has_interacted=false

echo "[+] Kiosk Data Protection Monitor Started."
echo "[+] Status: UNARMED (Waiting for first user interaction...)"

while true; do
    # Query GNOME's Mutter IdleMonitor via D-Bus
    raw_idle=$(gdbus call --session \
                         --dest org.gnome.Mutter.IdleMonitor \
                         --object-path /org/gnome/Mutter/IdleMonitor/Core \
                         --method org.gnome.Mutter.IdleMonitor.GetIdletime)
    
    # Extract the raw millisecond integer
    idle_ms=$(echo "$raw_idle" | awk '{print $2}' | tr -d ',)')

    # STATE 1: Unarmed. Wait for the idle time to drop near 0 (signaling a human arrived)
    if [ "$has_interacted" = false ]; then
        if [ "$idle_ms" -lt 2000 ]; then
            has_interacted=true
            echo "[+] User interaction detected! Monitor is now ARMED."
        fi
    
    # STATE 2: Armed. Monitor for 2 minutes of complete inactivity
    else
        if [ "$idle_ms" -ge "$IDLE_THRESHOLD" ]; then
            echo "[!] 2 minutes of inactivity reached. Displaying warning dialog..."

            # Launch the interactive Zenity dialog box
            zenity --question \
                   --title="Inactivity Warning" \
                   --text="Are you still using this computer?\n\nFor your privacy, this computer will automatically restart and wipe all session data in 30 seconds." \
                   --ok-label="Yes, keep working" \
                   --cancel-label="No, log me out" \
                   --timeout=$PROMPT_TIMEOUT \
                   --width=450 \
                   --modal

            # Capture Zenity's exit status
            # 0 = User clicked "Yes"
            # 1 = User clicked "No"
            # 5 = The 30-second timeout expired
            RESPONSE=$?

            if [ "$RESPONSE" -eq 0 ]; then
                echo "[+] User confirmed they are still here. Resetting idle tracker."
                # Clicking the button naturally resets idle_ms to 0, so loop continues normally.
            else
                echo "[-] Timeout reached ($RESPONSE). Executing secure reboot..."
                # Use systemctl to safely reboot the machine
                systemctl reboot
            fi
        fi
    fi

    # Poll every 2 seconds to keep CPU overhead practically zero
    sleep 2
done