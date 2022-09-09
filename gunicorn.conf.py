import os

workers = os.getenv("GUNICORN_WORKERS", "3")
threads = os.getenv("GUNICORN_THREADS", "1")
timeout = os.getenv("GUNICORN_TIMEOUT", "0")
bind = "0.0.0.0:" + os.getenv("PORT", "8000")
accesslog = "-"
errorlog = "-"
