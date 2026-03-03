FROM python:3.12-slim

WORKDIR /opt/gbapp

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY templates ./templates
COPY static ./static
COPY app.py ./
COPY models.py ./
COPY forms.py ./

RUN useradd -m app && chown -R app:app .

EXPOSE 8000
USER app

CMD ["sh", "-c", "sleep 10 && uvicorn app:app --host 0.0.0.0 --port 8000"]
