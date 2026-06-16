# syntax=docker/dockerfile:1

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

COPY pyproject.toml uv.lock README.md ./
COPY src ./src

RUN uv sync --frozen --no-dev --no-editable

FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH" \
    HM_API_HOST=0.0.0.0 \
    HM_API_PORT=8000 \
    HM_API_AUTO_LOGIN=1

WORKDIR /app

RUN addgroup --system app \
    && adduser --system --ingroup app --home /app app \
    && mkdir -p /app/cred \
    && chown -R app:app /app

COPY --from=builder --chown=app:app /app/.venv /app/.venv
COPY --chown=app:app docker/entrypoint.sh /usr/local/bin/hm-api-entrypoint

RUN chmod +x /usr/local/bin/hm-api-entrypoint

VOLUME ["/app/cred"]
EXPOSE 8000

USER app

ENTRYPOINT ["hm-api-entrypoint"]
CMD ["serve"]
