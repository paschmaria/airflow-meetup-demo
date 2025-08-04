FROM apache/airflow:3.0.3

USER root
COPY requirements.txt .

USER airflow
RUN pip install --no-cache-dir -r requirements.txt
