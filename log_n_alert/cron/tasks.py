from celery import Celery
import subprocess
import os

CELERY_BROKER_URL = 'redis://localhost:6379/0'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'

celery_app = Celery('tasks',
                    broker=CELERY_BROKER_URL,
                    backend=CELERY_RESULT_BACKEND)

@celery_app.task
def process_logs_task():
    script_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'process_logs.sh')
    subprocess.run(['bash', script_path])
    print(f"Executed log processing script: {script_path}")

if __name__ == '__main__':
    # Example of how to run the Celery worker (you'd usually do this in a separate terminal)
    # celery -A cron.tasks worker -l info
    pass