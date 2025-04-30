#!/bin/bash

LOG_FILE="tic_tac_toe.log"
ARCHIVE_DIR="log_archive"
RECIPIENT_EMAILS=("user1@example.com" "user2@example.com") # Add your recipient emails
SMTP_SERVER="your_smtp_server" # Replace with your SMTP server address
SMTP_PORT="your_smtp_port"     # Replace with your SMTP port
SMTP_USERNAME="your_smtp_username" # Replace with your SMTP username (if required)
SMTP_PASSWORD="your_smtp_password" # Replace with your SMTP password (if required)
EMAIL_SUBJECT="Tic-Tac-Toe Game Result Alert"

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Function to send email
send_email() {
  local recipient="$1"
  local subject="$2"
  local body="$3"

  if [[ -n "$SMTP_SERVER" ]]; then
    echo "$body" | mail -s "$subject" -S smtp="$SMTP_SERVER:$SMTP_PORT" -S smtp-auth=login -S smtp-auth-user="$SMTP_USERNAME" -S smtp-auth-password="$SMTP_PASSWORD" "$recipient"
    if [ $? -eq 0 ]; then
      echo "Email sent successfully to $recipient"
    else
      echo "Error sending email to $recipient"
    fi
  else
    echo "SMTP server not configured. Skipping email."
  fi
}

# Process new log entries
while IFS= read -r line; do
  if [[ "$line" == *"- INFO - Game Over -"* ]]; then
    winner=$(echo "$line" | grep -oP "Winner: \K\w+|Draw")
    timestamp=$(echo "$line" | awk '{print $1, $2}')
    board=$(echo "$line" | grep -oP "Board: \K\[.*?\]")

    if [[ "$winner" == "X" || "$winner" == "O" ]]; then
      message="The Tic-Tac-Toe game played at $timestamp has a winner: Player $winner. The final board was: $board"
    elif [[ "$winner" == "Draw" ]]; then
      message="The Tic-Tac-Toe game played at $timestamp ended in a draw. The final board was: $board"
    else
      message="Could not determine the winner from the log entry: $line"
    fi

    echo "Processing game result: $message"

    # Send email alert to all recipients
    for recipient in "${RECIPIENT_EMAILS[@]}"; do
      send_email "$recipient" "$EMAIL_SUBJECT" "$message"
    done
  fi
done < "$LOG_FILE"

# Archive the processed log file (optional - you might want to do this periodically)
timestamp_archive=$(date +%Y%m%d_%H%M%S)
mv "$LOG_FILE" "$ARCHIVE_DIR/tic_tac_toe_$timestamp_archive.log"
touch "$LOG_FILE" # Create a new empty log file

echo "Log file processed, archived, and alerts sent (if configured)."