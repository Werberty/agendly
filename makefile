.PHONY: up down build logs migrate makemigrations shell superuser test lint format typecheck

up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f api

migrate:
	docker compose run --rm api python manage.py migrate

makemigrations:
	docker compose run --rm api python manage.py makemigrations

shell:
	docker compose run --rm api python manage.py shell

superuser:
	docker compose run --rm api python manage.py createsuperuser

test:
	docker compose run --rm api pytest

lint:
	docker compose run --rm api ruff check .

format:
	docker compose run --rm api ruff format .

typecheck:
	docker compose run --rm api mypy .

manage:
	docker compose run --rm api python manage.py $(cmd)
