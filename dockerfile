# syntax=docker/dockerfile:1.7

# ---------- builder: instala dependências ----------
FROM python:3.14-slim AS builder

# use a mesma versão que você tem localmente (poetry --version)
ARG POETRY_VERSION=2.4.1

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Poetry fica só neste estágio, não vai para a imagem final
RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"

WORKDIR /app

# 1) só dependências (camada em cache enquanto pyproject/poetry.lock não mudarem)
COPY pyproject.toml poetry.lock ./
RUN --mount=type=cache,target=/root/.cache/pypoetry \
    poetry install --no-root

# 2) código do projeto
COPY . .


# ---------- dev: com pytest, ruff, mypy (compose local e CI) ----------
FROM builder AS dev
RUN --mount=type=cache,target=/root/.cache/pypoetry \
    poetry install --no-root
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]


# ---------- runtime: produção (último estágio = alvo padrão) ----------
FROM python:3.14-slim AS runtime

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=config.settings.prod \
    WEB_CONCURRENCY=3

RUN groupadd --system app && useradd --system --gid app --create-home app

WORKDIR /app
COPY --from=builder --chown=app:app /app /app

# arquivos estáticos (admin, Swagger). Valores fictícios só para o build.
# RUN SECRET_KEY=build-only DATABASE_URL=sqlite:////tmp/build.db \
#     python manage.py collectstatic --noinput

USER app
EXPOSE 8000

CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
