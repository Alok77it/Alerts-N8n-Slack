# Server Alerts Workflow for n8n

This n8n workflow monitors your server and sends alerts to a Slack channel when issues are detected. It checks system metrics, services, cron jobs, backups, and logs, then notifies the team if any problems arise.

---

## Features

- **Monitor CPU and RAM usage**  
  Alerts if CPU usage exceeds 80% or RAM usage exceeds 85%.

- **Check system services**  
  Notifies if any critical service is down.

- **Monitor cron jobs**  
  Alerts if any scheduled cron jobs fail.

- **Verify backups**  
  Sends an alert if backups are missing.

- **Watch for cert-manager issues**  
  Detects `CrashLoopBackOff` events in `cert-manager-cainjector` logs.

- **Slack notifications**  
  Sends formatted messages to the configured Slack channel.

---

## Workflow Nodes

1. **Schedule Trigger**  
   Triggers the workflow at defined intervals (configured in minutes).

2. **Execute a Command (SSH)**  
   Runs the server monitoring script (`server_monitor.py`) via SSH.

3. **Code**  
   Processes the script output, checks for issues, and prepares alert messages.

4. **Send a Message (Slack)**  
   Sends alerts (or "All systems operational" message) to a Slack channel.

---

## Setup Instructions

### 1. Prerequisites

- n8n installed (cloud or self-hosted)  
- Access to your server via SSH  
- Slack workspace and channel for alerts  
- Python installed on the monitored server with your monitoring script (`server_monitor.py`) ready

### 2. Configure Credentials

1. **SSH Credential**  
   - Add a credential in n8n for SSH access to your server.

2. **Slack Credential**  
   - Add a Slack API credential to n8n and ensure it has permission to post messages in your target channel.

### 3. Update Workflow Settings

- Set the interval in the **Schedule Trigger** node according to your desired monitoring frequency.
- Update the **Slack channel** in the **Send a Message** node.
- Ensure the **server monitoring script path** is correct in the **Execute a Command** node.

### 4. Activate Workflow

- Once everything is configured, activate the workflow in n8n. Alerts will now be sent automatically based on system status.

---

## Example Alert

⚠️ High CPU usage detected: 92%
⚠️ Service nginx is down!
⚠️ Backup is missing!
⚠️ Cron job failed: nightly_backup
⚠️ cert-manager-cainjector is in CrashLoopBackOff!


If no issues are found, the workflow sends:



✅ All systems operational.


---

## Contributing

Feel free to fork this repository and add custom checks or integrate with other notification platforms.

---
