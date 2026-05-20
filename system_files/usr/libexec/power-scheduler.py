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

def get_epoch_for_time(target_time_str, relative_to_days=0):
    target_date = datetime.now() + timedelta(days=relative_to_days)
    h, m = map(int, target_time_str.split(':'))
    target_datetime = target_date.replace(hour=h, minute=m, second=0, microsecond=0)
    return int(target_datetime.timestamp())

print("[+] Kiosk Smart Power Scheduler Started.")

while True:
    if not os.path.exists(CONFIG_PATH):
        print(f"[!] Warning: Configuration file missing at {CONFIG_PATH}. Retrying in 10s...")
        time.sleep(10)
        continue

    try:
        with open(CONFIG_PATH, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"[!] Error parsing JSON configuration: {e}. Retrying in 10s...")
        time.sleep(10)
        continue

    # Get current time information
    now = datetime.now()
    current_day = str(now.isoweekday())  # "1" = Monday, "7" = Sunday
    yesterday_day = str(1 if now.isoweekday() == 1 else now.isoweekday() - 1)
    current_mins = now.hour * 60 + now.minute

    today_rule = config["schedule"].get(current_day)
    yesterday_rule = config["schedule"].get(yesterday_day)

    should_sleep = False
    target_state = "awake"
    wake_epoch = None

    # 1. Evaluate Today's Rule Window
    if today_rule and today_rule["state"] != "awake":
        off_m = to_mins(today_rule["off_time"])
        on_m = to_mins(today_rule["on_time"])

        if off_m < on_m:  # Same-day window
            if off_m <= current_mins < on_m:
                should_sleep = True
                target_state = today_rule["state"]
                wake_epoch = get_epoch_for_time(today_rule["on_time"], 0)
        else:  # Overnight window crossing midnight
            if current_mins >= off_m:
                should_sleep = True
                target_state = today_rule["state"]
                wake_epoch = get_epoch_for_time(today_rule["on_time"], 1)

    # 2. Evaluate Yesterday's Rule Window (Post-midnight holdover check)
    if not should_sleep and yesterday_rule and yesterday_rule["state"] != "awake":
        off_m = to_mins(yesterday_rule["off_time"])
        on_m = to_mins(yesterday_rule["on_time"])

        if off_m > on_m:  # Yesterday had an overnight window
            if current_mins < on_m:
                should_sleep = True
                target_state = yesterday_rule["state"]
                wake_epoch = get_epoch_for_time(yesterday_rule["on_time"], 0)

    # 3. Enforce the Active Power State
    if should_sleep:
        # Action A: Just blank the monitor backlight
        if target_state == "screen-off":
            print("[!] Active Window: Display Blanking Enabled. Ensuring display is powered down.")
            subprocess.run("vbetool dpms off", shell=True)
            
        # Action B: Put the core system hardware to sleep or turn off completely
        elif target_state in ["suspend", "hibernate", "hybrid-sleep", "off"]:
            current_epoch = int(time.time())
            if wake_epoch and wake_epoch > current_epoch:
                print(f"[!] Active Window: State '{target_state}' Enforced. Sleeping via rtcwake until {datetime.fromtimestamp(wake_epoch)}")
                time.sleep(3) # Let logs flush cleanly
                
                # Passes the exact keyword ("suspend", "off", etc.) straight into rtcwake
                subprocess.run(f"rtcwake -m {target_state} -t {wake_epoch}", shell=True)
                print("[+] System woke up naturally or was manually interrupted. Re-evaluating schedule...")
    else:
        # Outside of a sleep window: ensure the display power is restored
        subprocess.run("vbetool dpms on", shell=True)

    # Check the schedule files once every minute
    time.sleep(60)