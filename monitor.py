#!/usr/bin/env python3
import os
import shlex
import subprocess
import sys
import psutil
import socket
import datetime
from typing import List, Tuple

# --- CONFIG ---
REMOTE_USER = os.getenv("REMOTE_USER", "root")
REMOTE_HOST = os.getenv("REMOTE_HOST", "69.10.34.254")
REMOTE_BACKUP_BASE = os.getenv("REMOTE_BACKUP_BASE", "/data/backup/main/Youstable")
THRESHOLD = int(os.getenv("THRESHOLD", "80"))  # % usage alert
BACKUP_PERIODS = os.getenv("BACKUP_PERIODS", "daily,weekly,monthly").split(",")

SSH_OPTS = os.getenv(
    "SSH_OPTS",
    "-o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"
)

# --- Logging Helpers ---
def log_info(msg: str) -> None:
    print(f"[INFO] {msg}")

def log_ok(msg: str) -> None:
    print(f"[OK] {msg}")

def log_err(msg: str) -> None:
    print(f"[ERROR] {msg}")

def log_alert(msg: str) -> None:
    print(f"[ALERT] {msg}")

# --- Remote Command ---
def run_remote_cmd(cmd: str) -> Tuple[int, str, str]:
    base = ["ssh"] + shlex.split(SSH_OPTS) + [f"{REMOTE_USER}@{REMOTE_HOST}"]
    full_cmd = base + [cmd]
    try:
        proc = subprocess.run(full_cmd, text=True, capture_output=True, check=False)
        return proc.returncode, proc.stdout.strip(), proc.stderr.strip()
    except Exception as e:
        return 255, "", str(e)

def list_remote_dir(path: str) -> List[str]:
    quoted = shlex.quote(path)
    rc, out, err = run_remote_cmd(f"ls -1 {quoted} 2>/dev/null")
    if rc != 0 or not out:
        return []
    return [line for line in out.splitlines() if line.strip()]

# --- Backup Check ---
def check_backup() -> bool:
    today = datetime.date.today()
    week = today.isocalendar()[1]   # ISO week number
    year = today.isocalendar()[0]   # ISO year
    month = today.strftime("%Y-%m")

    expected = {
        "daily": f"backup-{today.strftime('%Y-%m-%d')}",
        "weekly": f"backup-{year}-W{week:02d}",
        "monthly": f"backup-{month}",
    }

    ok = True
    for period in [p.strip() for p in BACKUP_PERIODS if p.strip()]:
        path = f"{REMOTE_BACKUP_BASE.rstrip('/')}/{period}"
        backups = list_remote_dir(path)

        if not backups:
            log_err(f"No {period} backups found at {path}!")
            ok = False
            continue

        backups.sort()
        latest = backups[-1]

        if expected.get(period) in backups:
            log_ok(f"{period.capitalize()} backup found ✅ : {expected[period]}")
        else:
            log_alert(f"{period.capitalize()} backup MISSING ❌ (expected {expected[period]})")
            log_info(f"Latest available {period} backup: {latest}")
            ok = False

    return ok

# --- System Check ---
def check_system(threshold: int) -> None:
    try:
        hostname = socket.gethostname()
        log_info(f"Hostname: {hostname}")
    except Exception:
        log_info("Hostname: Unknown")

    # CPU Usage
    cpu_usage = psutil.cpu_percent(interval=2)
    log_info(f"CPU Usage: {cpu_usage:.0f}%")
    if cpu_usage > threshold:
        log_alert("High CPU usage!")

    # RAM Usage
    ram = psutil.virtual_memory()
    log_info(f"RAM Usage: {ram.percent:.0f}%")
    if ram.percent > threshold:
        log_alert("High RAM usage!")

    # Disk Usage (/)
    disk = psutil.disk_usage('/')
    log_info(f"Disk Usage: {disk.percent:.0f}%")
    if disk.percent > threshold:
        log_alert("High storage usage!")

# --- Main ---
def main() -> int:
    check_system(THRESHOLD)
    backup_ok = check_backup()

    if backup_ok:
        print("[FINAL STATUS] ✅ All required backups (daily/weekly/monthly) exist & system OK.")
        return 0
    else:
        print("[FINAL STATUS] ❌ Missing backups detected or system issues.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
