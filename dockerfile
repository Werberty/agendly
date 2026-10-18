FROM python:3.14-slim

# use a mesma versão do seu Poetry local (poetry --version)
ARG POETRY_VERSION=2.4.1

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    PATH="/app/.venv/bin:$PATH"

RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"

WORKDIR /app

# dependências primeiro (camada em cache)
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root

# código
COPY . .

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]