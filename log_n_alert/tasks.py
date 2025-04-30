from celery import Celery
import subprocess

celery_app = Celery('tasks', broker='redis://localhost:6379/0')  # Configure your broker

@celery_app.task
def process_logs_task():
    subprocess.run(['/path/to/your/process_logs.sh'])  # Use subprocess for security