#!/bin/bash

LOG_FILE="tic_tac_toe.log"
S3_BUCKET="tictactoe-log-bucket"
AWS_CLI="$(which aws)"
LOG_OUTPUT="/tmp/cron-upload.log"

if [ -s "$LOG_FILE" ]; then
  echo "$(date): Uploading $LOG_FILE to S3..." >> "$LOG_OUTPUT"
  $AWS_CLI s3 cp "$LOG_FILE" s3://$S3_BUCKET/ --only-show-errors >> "$LOG_OUTPUT" 2>&1
else
  echo "$(date): Log file is empty or missing, skipping upload." >> "$LOG_OUTPUT"
fi
