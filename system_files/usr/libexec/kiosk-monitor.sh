#!/bin/bash

# Configuration (Time in milliseconds)
# 2 minutes = 120000 ms
IDLE_THRESHOLD=120000 
# Time given to user to respond (in seconds)
PROMPT_TIMEOUT=30

WARNING_TITLE="Inaktivitet Opdaget"
WARNING_MESSAGE="Er du der stadigvæk?\n\nKlik på knappen nedenfor for at fortsætte. Ellers vil denne computer automatisk genstarte og slette alle sessiondata om ${PROMPT_TIMEOUT} sekunder."
BUTTON_LABEL="Jeg er her stadigvæk!"


# State Tracker: Starts as false so we don't reboot an empty computer
has_interacted=false

echo "[+] Kiosk Data Protection Monitor Started."
echo "[+] Status: UNARMED (Waiting for first user interaction...)"

while true; do
    # 1. Check if an application (like YouTube or VLC) has inhibited the idle state
    raw_inhibited=$(gdbus call --session \
                               --dest org.gnome.SessionManager \
                               --object-path /org/gnome/SessionManager \
                               --method org.gnome.SessionManager.IsInhibited 8)

    if [[ "$raw_inhibited" == *"true"* ]]; then
        has_interacted=true
        echo "[~] Media playback / Session inhibition detected. Postponing idle checks..."
        sleep 10  
        continue
    fi

    # 2. Query GNOME's Mutter IdleMonitor via D-Bus
    raw_idle=$(gdbus call --session \
                         --dest org.gnome.Mutter.IdleMonitor \
                         --object-path /org/gnome/Mutter/IdleMonitor/Core \
                         --method org.gnome.Mutter.IdleMonitor.GetIdletime)
    
    idle_ms=$(echo "$raw_idle" | awk '{print $2}' | tr -d ',)')

    if [[ ! "$idle_ms" =~ ^[0-9]+$ ]]; then
        echo "[!] Warning: Invalid D-Bus response received. Retrying in next cycle..."
        sleep 2
        continue
    fi

    # STATE 1: Unarmed. Wait for the idle time to drop near 0 (signaling a human arrived)
    if [ "$has_interacted" = false ]; then
        if [ "$idle_ms" -lt 2000 ]; then
            has_interacted=true
            echo "[+] User interaction detected! Monitor is now ARMED."
        fi
    
    # STATE 2: Armed. Monitor for 2 minutes of complete inactivity
    else
        if [ "$idle_ms" -ge "$IDLE_THRESHOLD" ]; then
            echo "[!] 2 minutes of inactivity reached. Displaying single-button warning..."

            zenity --warning \
                   --title="$WARNING_TITLE" \
                   --text="$WARNING_MESSAGE" \
                   --ok-label="$BUTTON_LABEL" \
                   --timeout=$PROMPT_TIMEOUT \
                   --width=450 \
                   --modal

            RESPONSE=$?

            if [ "$RESPONSE" -eq 0 ]; then
                echo "[+] User confirmed presence. Resetting idle tracker."
            else
                echo "[-] Timeout reached or dialog closed ($RESPONSE). Executing secure kexec fast reboot..."
                # UPDATED: Replaced standard reboot with passwordless sudo kexec
                sudo /usr/bin/systemctl kexec
            fi
        fi
    fi

    sleep 2
done