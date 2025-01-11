# Frontend Dockerfile
FROM python:3.9.21-slim

WORKDIR /app

# Install dependencies
COPY frontend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY frontend/. .

# Set environment variables
ENV FLASK_APP=frontend/app.py
ENV FLASK_ENV=development
ENV PYTHONPATH=/app

EXPOSE 5000

CMD ["python", "-m","flask", "run", "--host=0.0.0.0", "--port=5000"]

#CMD ["while true; do echo 'running'; done"]