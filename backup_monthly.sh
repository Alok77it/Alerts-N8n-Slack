#!/bin/bash
#
# Monthly Backup Script for /home
# Deletes backups older than 365 days (~12 months)
#

SRC="/home"
DEST="/data/backup/main/Youstable/monthly"
USER="root"
HOST="69.10.34.254"
DATE=$(date +%Y-%m)   # Year-Month format, e.g. 2025-08

echo "[INFO] Starting monthly backup: $DATE"

rsync -av --delete "$SRC" "$USER@$HOST:$DEST/backup-$DATE/"

echo "[INFO] Checking for old backups on $HOST..."
ssh $USER@$HOST "
  for dir in \$(find $DEST -maxdepth 1 -type d -name 'backup-*'); do
    if [ \$(find \"\$dir\" -maxdepth 0 -mtime +365 | wc -l) -gt 0 ]; then
      echo \"[DELETE] Removing \$dir (older than 12 months)\"
      rm -rf \"\$dir\"
    else
      echo \"[KEEP]   Keeping \$dir (not older than 12 months)\"
    fi
  done
"

echo "[INFO] Monthly backup completed: $DATE"

