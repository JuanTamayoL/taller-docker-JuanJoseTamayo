FROM python:3.12-slim-bookworm AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim-bookworm

WORKDIR /app

COPY --from=builder /install /usr/local

COPY prestamos/ ./prestamos/

RUN useradd --create-home --uid 1000 appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 9000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:9000/salud', timeout=2)" || exit 1

CMD ["uvicorn", "prestamos.servidor:app", "--host", "0.0.0.0", "--port", "9000"]
