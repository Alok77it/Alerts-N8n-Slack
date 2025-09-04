#!/bin/bash
#
# Daily Backup Script for /home using rsync
# Keeps backups as folders and deletes backups older than 7 days
#

# --- CONFIG ---
SRC="/home/"
DEST="/data/backup/main/Youstable/daily"
USER="root"
HOST="69.10.34.254"

# --- DATE ---
DATE=$(date +%F)
BACKUP_DIR="backup-$DATE"

echo "[INFO] Starting daily backup: $DATE"

# --- CREATE REMOTE DIRECTORY ---
ssh $USER@$HOST "mkdir -p $DEST/$BACKUP_DIR"

# --- RSYNC TO REMOTE (with compression, verbose, delete old files inside daily folder) ---
rsync -avz --delete "$SRC" "$USER@$HOST:$DEST/$BACKUP_DIR/"

# --- VERIFY ON REMOTE ---
echo "[INFO] Verifying backup on $HOST ..."
ssh $USER@$HOST "
  if [ -d $DEST/$BACKUP_DIR ]; then
    SIZE=\$(du -sh $DEST/$BACKUP_DIR | cut -f1)
    MODDATE=\$(stat -c%y $DEST/$BACKUP_DIR)
    echo \"[OK] Backup exists: $DEST/$BACKUP_DIR\"
    echo \"     Size: \$SIZE\"
    echo \"     Modified: \$MODDATE\"
  else
    echo \"[ERROR] Backup directory not found!\"
    exit 1
  fi
"

# --- RETENTION: DELETE BACKUPS OLDER THAN 7 DAYS ---
echo "[INFO] Cleaning old backups on $HOST ..."
ssh $USER@$HOST "
  find $DEST -maxdepth 1 -type d -name 'backup-*' -mtime +7 -print -exec rm -rf {} \;
"

echo "[INFO] Daily backup completed: $DATE"
