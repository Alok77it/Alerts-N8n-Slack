#!/bin/bash
# ===========================================================
#  Daily Backup Report (Current Date Only)
#  Author: ChatGPT
#  Description:
#    Generates a summary of today's backups under each client directory.
# ===========================================================

BACKUP_ROOT="/data/main"            # Base directory for all client backups
DATE=$(date +"%Y-%m-%d")            # Today’s date

echo ""
echo "📅 Daily Backup Report"
echo "Date: $DATE"
echo "Base Directory: $BACKUP_ROOT"
echo "Generated on: $(date)"
echo "============================================================="
echo ""

# Check if base directory exists
if [ ! -d "$BACKUP_ROOT" ]; then
    echo "❌ Error: Backup root directory '$BACKUP_ROOT' not found."
    exit 1
fi

# Loop through client directories
for dir in "$BACKUP_ROOT"/*/; do
    [ ! -d "$dir" ] && continue
    CLIENT=$(basename "$dir")
    DAILY_PATH="$dir/daily/$DATE"

    # Skip if today's backup directory doesn't exist
    if [ ! -d "$DAILY_PATH" ]; then
        continue
    fi

    echo "📂 Client: $CLIENT"
    echo "   Backup Path: $DAILY_PATH"

    # Find and list backup files for today
    find "$DAILY_PATH" -type f | sort | while read -r file; do
        SIZE=$(du -h --apparent-size "$file" | awk '{print $1}')
        REL_PATH="${file#$DAILY_PATH/}"
        echo "   ├── $SIZE    $REL_PATH"
    done

    echo ""
done

echo "============================================================="
echo "✅ Backup report for $DATE completed successfully."
