FROM docker.io/library/python:3.11.6-slim-bookworm

WORKDIR /app
COPY . .

ARG otel

RUN pip install -r requirements.txt \
    && if [ "$otel" = 'y' ]; then \
         pip install opentelemetry-distro opentelemetry-exporter-otlp \
         && opentelemetry-bootstrap -a install; \
       fi

CMD ["sleep", "1000000"]
