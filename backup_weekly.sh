#!/bin/bash
#
# Weekly Backup Script for /home
# Deletes backups older than 30 days (~4 weeks)
#

SRC="/home"
DEST="/data/backup/main/Youstable/weekly"
USER="root"
HOST="69.10.34.254"
DATE=$(date +%G-W%V)   # ISO Week format, e.g. 2025-W34

echo "[INFO] Starting weekly backup: $DATE"

rsync -av --delete "$SRC" "$USER@$HOST:$DEST/backup-$DATE/"

echo "[INFO] Checking for old backups on $HOST..."
ssh $USER@$HOST "
  for dir in \$(find $DEST -maxdepth 1 -type d -name 'backup-*'); do
    if [ \$(find \"\$dir\" -maxdepth 0 -mtime +30 | wc -l) -gt 0 ]; then
      echo \"[DELETE] Removing \$dir (older than 30 days)\"
      rm -rf \"\$dir\"
    else
      echo \"[KEEP]   Keeping \$dir (not older than 30 days)\"
    fi
  done
"

echo "[INFO] Weekly backup completed: $DATE"
