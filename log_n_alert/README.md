# Overview
This is a tic-tac-toe game, built with flask python web framework. The data of the game (moves and winner) is stored, archived and can be mailed to anyone.

# Play the game
- You can play it on your browser by cloning the repo and running this on your terminal:
```bash
cd bashing/log_n_alert
pip install flask
flask run
```

- Open your web browser and go to http://127.0.0.1:5000/

- When the game ends, a log file containing the moves made and the eventual winner of the game is generated.

# Local logging alert
The process_log.sh file, which can be run with `./process_log.sh`, is supposed to archive and mail the logs to specified emails (change the recipient emails), if smtp server is configured.



# AWS Alerting

-  Goal
    - Create an alert system for logging the events in a game
- Game: Tic-tac-toe
- link: https://github.com/egbeyon/bashing/tree/main/log_n_alert


# Resources and Services
- EC2
- VPC
- AWS CLI
- AWS IAM
- AWS S3
- AWS LAMBDA
- AWS CLOUDWATCH
- AWS SNS

# Process
- Clone and run the application

- Create S3 bucket to store the log file
  - the app generates logs and stores them in `tic_tac_toe.log` file - this file is created, if not already existing in the app's directory, everytime the game begins
  - a cronjob runs the file `upload-log.sh` every minute, if a game has started (perhaps modify post per event).
  - the `upload-log.sh` file sends the log file to the s3 bucket


- Lambda Function: 
  - reads the file from S3
  - converts the content into JSON format
  - sends it to an SNS topic.


- S3 Bucket Notification
  - notifies the Lambda function when a new log file is uploaded.


- SNS Topic: 
  - subscribers receive emails when the Lambda publishes a message.

  - NB: the `process_log.sh` file should accomplish this task without the need for AWS s3, lambda and SNS cloud services, if SMTP is installed on the linux machine.

# Breaking it down

1. Running the app
  - clone and run tic-tac-toe app
```bash
git clone https://github.com/egbeyon/bashing.git
cd bashing/log_n_alert # home directory for the tic-tac-toe app
pip install flask
python3 app.py
```

2. Create S3 bucket to store the log file
   - install aws cli
   - configure aws `aws configure`
   - create s3 bucket
```bash
aws s3 mb s3://<unique_bucket_name>
```

3. Create cronjon to run upload-log.sh 
   - run the command `crontab e`
   - add `*/1 * * * * /home/ubuntu/upload-log.sh`
   - replace the directory with the correct one

4. Create sns topic and subscribers
```bash
aws sns create-topic --name TicTacToeLogTopic
aws sns subscribe \
  --topic-arn arn:aws:sns:<REGION>:<ACCOUNT_ID>:TicTacToeLogTopic \
  --protocol email \
  --notification-endpoint <your_email@example.com>

```

5. Create lambda function (python 3)
   - create and deploy python function named ProcessTicTacToeLog. Replace the parameters in the variables where needed
```python
import boto3
import json
import gzip
import os

s3 = boto3.client('s3')
sns = boto3.client('sns')

SNS_TOPIC_ARN = 'arn:aws:sns:<REGION>:<ACCOUNT_ID>:TicTacToeLogTopic'

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        response = s3.get_object(Bucket=bucket, Key=key)
        raw_log = response['Body'].read().decode('utf-8')
        
        # Clean up log into JSON-like entries
        log_lines = raw_log.strip().splitlines()
        events = [{"event": line} for line in log_lines if line.strip()]
        
        message = json.dumps({"log_events": events}, indent=2)
        
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="Tic Tac Toe Game Log",
            Message=message
        )
        
        return {
            'statusCode': 200,
            'body': 'SNS Notification sent.'
        }
```
   - create permissions (or do it manually on the console):
```bash
aws lambda add-permission \
  --function-name ProcessTicTacToeLog \
  --principal s3.amazonaws.com \
  --statement-id S3Invoke \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::tictactoe-log-bucket
```

6. Configure s3 bucket to trigger lambda
```bash
aws s3api put-bucket-notification-configuration --bucket tictactoe-log-bucket --notification-configuration '{
  "LambdaFunctionConfigurations": [
    {
      "Id": "NotifyLambdaOnUpload",
      "LambdaFunctionArn": "arn:aws:lambda:<REGION>:<ACCOUNT_ID>:function:ProcessTicTacToeLog",
      "Events": ["s3:ObjectCreated:Put"]
    }
  ]
}'
```

7. Check to the subscribed emails for the logs


8. Cleanup when done - remember to delete all resources created.


# Possible Issues

1. If s3 bucket is not receiving the logs
  - check if the logs where sent
```bash
cat /tmp/cron-upload.log
```
  - verify that the setup is fine, use test case
```
echo "test log" > test.log
aws s3 cp test.log s3://tictactoe-log-bucket/
```
  - ensure directories are correct across files and commands

2. Check the cloudwatch log groups to verify the logs are triggered by lambda

3. Ensure permissions are correctly configured.