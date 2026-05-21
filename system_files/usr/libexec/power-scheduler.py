#!/usr/bin/env python3
import os
import json
import time
import subprocess
from datetime import datetime, timedelta

CONFIG_PATH = "/etc/kiosk/power-schedule.json"

def to_mins(time_str):
    h, m = map(int, time_str.split(':'))
    return h * 60 + m

print("[+] Kiosk Operational Hours Power Scheduler Started.")

while True:
    if not os.path.exists(CONFIG_PATH):
        time.sleep(10)
        continue

    try:
        with open(CONFIG_PATH, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"[!] JSON Error: {e}")
        time.sleep(10)
        continue

    now = datetime.now()
    current_mins = now.hour * 60 + now.minute
    today_num = now.isoweekday() # 1 = Monday, 7 = Sunday
    
    today_rule = config["schedule"][str(today_num)]
    is_closed_today = (today_rule["open_time"] == today_rule["close_time"])
    
    should_sleep = False
    target_state = today_rule["state"]
    
    # Check if we should be awake right now
    if is_closed_today:
        should_sleep = True
    else:
        open_mins = to_mins(today_rule["open_time"])
        close_mins = to_mins(today_rule["close_time"])
        if open_mins <= current_mins < close_mins:
            should_sleep = False # We are within open hours!
        else:
            should_sleep = True

    if should_sleep:
        wake_datetime = None
        
        # Lookahead Engine: Scan up to 7 days in advance to find the next opening target
        for days_ahead in range(0, 8):
            check_date = now + timedelta(days=days_ahead)
            check_day_num = check_date.isoweekday()
            rule = config["schedule"][str(check_day_num)]
            
            # If the lookahead day is closed all day, skip it entirely
            if rule["open_time"] == rule["close_time"]:
                continue
                
            open_mins = to_mins(rule["open_time"])
            
            if days_ahead == 0:
                # If checking today, ensure we haven't already passed the opening time
                if current_mins < open_mins:
                    h, m = map(int, rule["open_time"].split(':'))
                    wake_datetime = check_date.replace(hour=h, minute=m, second=0, microsecond=0)
                    break
            else:
                # The first future day that is open becomes our target
                h, m = map(int, rule["open_time"].split(':'))
                wake_datetime = check_date.replace(hour=h, minute=m, second=0, microsecond=0)
                break

        if wake_datetime:
            wake_epoch = int(wake_datetime.timestamp())
            
            if target_state == "screen-off":
                print(f"[!] Closed. Blanking screen until {wake_datetime}")
                subprocess.run("vbetool dpms off", shell=True)
            elif target_state in ["suspend", "hibernate", "hybrid-sleep", "off"]:
                rtcwake_modes = {"suspend": "mem", "hibernate": "disk", "hybrid-sleep": "hybrid", "off": "off"}
                rtc_mode = rtcwake_modes.get(target_state, "mem")
                
                print(f"[!] Closed. Engaging hardware '{target_state}' state. Alarm set for {wake_datetime}")
                time.sleep(3) # Log flush buffer
                subprocess.run(f"rtcwake -m {rtc_mode} -t {wake_epoch}", shell=True)
                print("[+] System emerged from sleep. Re-evaluating calendar...")
    else:
        # Open hours: Ensure display backlight is actively powered on
        subprocess.run("vbetool dpms on", shell=True)

    time.sleep(60)