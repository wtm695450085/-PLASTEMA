FROM python:3.13-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
RUN useradd --create-home --uid 10001 appuser
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
COPY materials.py .
COPY inventory.py .
COPY machines.py .
COPY receipts.py .
COPY orders.py .
COPY order_seed.py .
COPY molds.py .
COPY prod_stats.py .
COPY settlement.py .
COPY fg.py .
COPY shell.py .
COPY changelog.py .
COPY seed seed
COPY templates templates
COPY static static
RUN mkdir -p /data && chown -R appuser:appuser /app /data
USER appuser
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "4", "--timeout", "30", "app:app"]
