FROM python:3.10.4-slim-bullseye

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    POETRY_VERSION=1.2.0 

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

RUN apt-get update \
    && apt-get install --no-install-recommends -y curl libpq-dev build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.2.0

WORKDIR $PYSETUP_PATH

COPY poetry.lock pyproject.toml ./
RUN poetry install --only main --no-root

RUN addgroup --system app && adduser --system --group app
USER app

WORKDIR /app
COPY --chown=app:app . .

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "--worker-tmp-dir", "/dev/shm", "django_dx.wsgi:application"]
