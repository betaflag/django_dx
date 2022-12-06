# django_dx

Supercharge your Django Development Experience with these tools and concepts 🚀

- [pyenv](#pyenv)
- [poetry](#poetry)
- [pylint](#pylint)
- [isort](#isort)
- [autopep8](#autopep8)
- [python-dotenv](#python-dotenv)
- [pytest](#pytest)
- [gunicorn](#gunicorn)
- [django-cache-framework](#django-cache-framework)
- [celery](#celery)
- [docker-compose](#docker-compose)
- [docker](#docker)
- [dependabot](#dependabot)
- [github-actions](#github-actions)

## Pyenv

[pyenv](https://github.com/pyenv/pyenv) allows to manage multiple python version. This is useful when you are working on multiple Django application over the time. It also make sure everyone working on the project uses the same python version.

### Pyenv Installation

```sh
brew install pyenv
```

There's a few post-installation steps, I use **zsh** :

```sh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

### Pyenv Usage

Create a `.python-version` at the root of your Django project with the python version that it is using.

```sh
cd django-project/
echo "3.10.8" > .python-version
```

Now, when you `cd` that directory, pyenv will make sure this specific version of the python interpreter is activated. If it's not installed, it will prompt you to do so.

Make sure to commit this file to git so every one working on the project will share the same python version. Also, other tools like VSCode and [setup-python](https://github.com/actions/setup-python) Github Action use this file.

There's a plugin to also manage virtual environment with pyenv but I prefer using Poetry instead.

## Poetry

[poetry](https://python-poetry.org/) is a wonderful tool that manages python dependencies and virtual environment in a way similar to NPM's package.json and Ruby's bundler. It has a few features that makes life simpler than using pip and it's also wonderfully integrated into VSCode.

### Poetry Installation

```sh
curl -sSL https://install.python-poetry.org | python3 -
```

There's a post-installation step, I use **zsh** :

```
poetry completions zsh > ~/.zfunc/_poetry`
```

### Poetry Usage

```sh
cd django-project/
poetry init
poetry add Django # latest version
poetry add Django@3.2.16 # specific version
poetry add psycopg2 gunicorn celery # add your other dependencies
poetry add -D isort pytest pylint # add development-only dependencies
```

Once your dependencies are installed you can activate your environment with

```sh
poetry shell
```

However, I'm always on the VSCode terminal and its activated automatically.

### Poetry VSCode integration

VSCode should detect poetry environment automatically. It will provide autocompletion and source code links. You might need to select it with `Select python interpreter` command.

## Pylint

[pylint](https://pylint.pycqa.org/en/latest/) is a static code analyzer that helps you enforce best practices and python standards. 

### Pylint Installation

I'm using the `pylint-django` plugin that includes a dependency on pylint. It adds some configuration options for Django projects.

```sh
poetry add -D pylint-django
```

Create `.pylintrc` file at the root of your project

```ini
[MASTER]
load-plugins=pylint_django, pylint_django.checkers.migrations
django-settings-module=django_dx.settings

[FORMAT]
max-line-length=120

[MESSAGES CONTROL]
disable=missing-docstring
```

Change **django_dx.settings** for your project settings.py path

### Pylint VSCode integration

VSCode can display pylint information in the editor as you code. Here's my configuration in `.vscode/settings.json`:

```json
{
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.linting.lintOnSave": true,
}
```

## isort

[isort](https://pycqa.github.io/isort/) is a small tool to sort your imports.

```sh
poetry add -D isort
```

### isort VSCode integration

VSCode can sort your import with the `Python Refactor: Sort Imports` command.

```json
{
    "python.sortImports.args": ["--atomic"],
    "[python]": {
        "editor.codeActionsOnSave": {
            "source.organizeImports": true
        },
    },
}
```

`atomic` setting makes sure it doesn't save the file if it contains a syntax error.


## autopep8

[autopep8](https://pypi.org/project/autopep8/) automatically formats your code by following the PEP 8 style guide.

```sh
poestry add -D autopep8
```

### autopep8 VSCode integration

Like the other tools, it's dierctly integrated with VSCode and you just need to turn it on. I only change the max-line-length to 120 because I find the default (80) to small.

```json
{
    "python.formatting.provider": "autopep8",
    "python.formatting.autopep8Args": [
        "--max-line-length=120"
    ],
    "[python]": {
        "editor.formatOnSave": true,
    }
}
```

## python-dotenv

[python-dotenv](https://saurabh-kumar.com/python-dotenv/) reads from .env and sets them as environnement variables. This is part of the [12 factors](https://12factor.net/config) methodology :

> The twelve-factor app stores config in environment variables (often shortened to env vars or env). Env vars are easy to change between deploys without changing any code; unlike config files, there is little chance of them being checked into the code repo accidentally; and unlike custom config files, or other config mechanisms such as Java System Properties, they are a language- and OS-agnostic standard.

Any config in settings.py that is secret or that change between environment should be replaced with an environment variable.

### python-dotenv Installation

```sh
poetry add python-dotenv
```

### python-dotenv Usage

Add this to the top of your `settings.json`

```py
from dotenv import load_dotenv

load_dotenv()
```

Replace the settings like this

```py
SECRET_KEY = 'django-insecure-me1pahb48s9bzqx0tq6_3g2hwxg%u(bh5fe#gsf_+5*(6@7so7'
```

With `os.getenv` like this

```sh
SECRET_KEY = os.getenv('SECRET_KEY', 'django-insecure-me1pahb48s9bzqx0tq6_3g2hwxg%u(bh5fe#gsf_+5*(6@7so7')
```

Create a `.env` at the root of your project

```sh
SECRET_KEY=secure-key-pj4o24clknlvxo3opdfg0-i4fdpojfg
```

Do not commit this file. The env file is unique to each environment, if you commit the file, it will be read in production.

### Database

I configure the database with defaults that are also set in `docker-compose.yml`. This allow anyone to clone the project and `docker compose up` the project to have it work without configuring any database. It also allow the production environment to override this config easily.

```py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        "NAME": os.getenv("DB_NAME", "django_dx"),
        "USER": os.getenv("DB_USER", "django_dx"),
        "PASSWORD": os.getenv("DB_PASSWORD", "django_dx"),
        "HOST": os.getenv("DB_HOST", "127.0.0.1"),
        "PORT": os.getenv("DB_PORT", "5432"),
    }
}
```

### Production (and other environments)

To configure an environment you can either use environment variables that you configure in the OS or create/copy a secret `.env` file specific for this environment at the root of the code base.

Many managed production environment like Heroku, App Engine, etc to provide you with an interface to create environment variable. Docker and Docker Compose also have settings to help you configure env variables.

## Pytest

[pytest](https://docs.pytest.org/) is a unit test framework that improves on Python's unittest library. It's a drop-in replacement with some extra features that are very useful like running the tests directly in VSCode.

### Pytest Installation

I use `pytest-django` plugin which includes the dependency on `pytest` and allow configuration of Django.

```sh
poetry add -D pytest-django
```

Create `pytest.ini` at the root of your project

```ini
[pytest]
DJANGO_SETTINGS_MODULE = django_dx.settings
python_files = tests.py test_*.py *_tests.py
```

Replace `django_dx.settings` with the path to your `settings.py`.

### Pytest Usage

Simply add your tests as usual in your app `tests.py` file. And simply run

```sh
pytest
```

The test will show in VSCode in the testing tab. You'll be able to run tests individually and also debug them.

### Pytest Tips

If the `tests.py` file gets too large, you can split them by creating a `tests` folder like this:

```sh
your_app/
  tests/
    __init__.py
    a_tests.py
    b_tests.py
```

## Gunicorn

Sooner or later you'll want to make your application available to other people. The internal server that you starts with `python manage.py runserver` is a development server not suited for production. You need a production-ready application server.

[Gunicorn](https://gunicorn.org/) is one of the most popular option. It's scalable and easy to use.

### Gunicorn Installation

```sh
poetry add gunicorn
```

Create `gunicorn.conf.py` at the root of your project

```py
import os

workers = os.getenv("GUNICORN_WORKERS", "3")
threads = os.getenv("GUNICORN_THREADS", "1")
timeout = os.getenv("GUNICORN_TIMEOUT", "0")
bind = "0.0.0.0:" + os.getenv("PORT", "8000")
accesslog = "-"
errorlog = "-"
```

All these options can also be passed to the gunicorn command line executable but I prefer to add them like this to use env variable. Each servers can be configured with own CPU/RAM to use a different amount of workers and threads.

### Gunicorn Usage

You can run gunicorn at any time with this:

```sh
gunicorn django_dx.wsgi:application
```

You will want to keep using `runserver` in development because of the autoreload.

### Gunicorn Tips

Configure workers with this rule:

> A positive integer generally in the 2-4 x $(NUM_CORES) range. You’ll want to vary this a bit to find the best for your particular application’s work load.

## Django Cache Framework

### DCF Installation

It's already part of Django and simply needs to be activated in `settings.py`:

```py
# Cache
# https://docs.djangoproject.com/en/4.1/topics/cache/

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': os.getenv('REDIS_URL', 'redis://127.0.0.1:6379'),
    }
}
```

### DCF Usage

[https://docs.djangoproject.com/en/4.1/topics/cache/](https://docs.djangoproject.com/en/4.1/topics/cache/)

## Celery

[Celery](https://docs.celeryq.dev/) is an asynchronous task queue to run background task. Use it to asynchronously run any piece of code fetching or pushing to external services or methods that takes some time to process.

### Celery Installation

```sh
poetry add "celery[redis]"
```

Change your project init file (mine is `django_dx/django_dx/__init__.py` to include this:

```py
# This will make sure the app is always imported when
# Django starts so that shared_task will use this app.
from .celery import app as celery_app

__all__ = ('celery_app',)
```

Add `celery.py` in your project folder (mine is `django_dx/django_dx/celery.py`):

```py
import os

from celery import Celery

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_dx.settings')

app = Celery('django_dx')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django apps.
app.autodiscover_tasks()
```

Change the reference to django_dx to the name of your project

Add this to your `settings.py`

```py
# Celery
# https://docs.celeryq.dev/en/stable/django/first-steps-with-django.html

CELERY_BROKER_URL = os.getenv("REDIS_URL", "redis://127.0.0.1:6379")
CELERY_RESULT_BACKEND = os.getenv("REDIS_URL", "redis://127.0.0.1:6379")
```

### Celery Usage

Add your task in `tasks.py` in your django apps.

```py
# my_app/tasks.py

from celery import shared_task

@shared_task
def add(x, y):
    return x + y
```

You can call this task anywhere like this:

```py
from my_app.tasks import add

add.delay(1, 2)
```

You need to start a worker to process the tasks. Note that the workers don't support autoreloading unfortunately.

```py
celery -A proj worker -l INFO
```

### Celery Tips: Autoretry

Use autoretry make sending emails resilient to SMTP failures.

```py
@shared_task(autoretry_for=(SMTPException,), max_retries=36, default_retry_delay=300)
def send_email(...)
    ...
```

This will retry sending the email every 5 minutes for 3 hours.

### Celery Tips: Queuing tasks in production

When I want to manually queue a background task in production, I sometimes connect to a server and use django's `shell` command:

```sh
python manage.py shell

python> from my_app.tasks import add
python> add.delay(1, 2)
```

When connecting to a production server is restricted (and it should be!), you can use a Django migration to queue a task:

```py
from django.db import migrations
from my_app.tasks import add

def queue_task(apps, schema_editor):
    add.delay(1, 2)

class Migration(migrations.Migration):

    dependencies = [
        # Dependencies to other migrations
    ]

    operations = [
        migrations.RunPython(queue_task, reverse_code=migrations.RunPython.noop, elidable=True),
    ]
```

The `elidable=True` option will eliminate this migration when you run `squashmigrations`.

## Docker Compose

I use Docker Compose to easily spin up services required by my application in development so any contributor won't have to download and configure them.

The `docker-compose.yml` file looks like this:

```yml
version: "3.9"
services:
  redis:
    image: redis:alpine
    ports:
      - 6379:6379

  postgres:
    image: postgres
    environment:
      POSTGRES_USER: django_dx
      POSTGRES_PASSWORD: django_dx
      PGDATA: /data/postgres
    ports:
      - 5432:5432
    volumes:
       - django_dx_pgdata:/data/postgres

  adminer:
    image: adminer
    ports:
      - 8080:8080
      
volumes:
  django_dx_pgdata:
```

### Usage

Simply spin up the services with this command

```sh
docker compose up -d
```

And then you can run the develoment server as usual, without having to install and configure postgres and redis

```sh
python manage.py runserver
```

### Docker Compose Tips: Dev defaults

I try to set the defaults value in the `settings.py` file to the coniguration of the services in the `docker-compose.yml`. The reason is that it makes it easy for new contributor to start the project without having to configure anything without compromising flexibility of setting the production configuration with environment variable.

## Docker

I use [Docker Desktop  for Mac](https://docs.docker.com/desktop/install/mac-install/).

The production `Dockerfile` looks like this:

```Dockerfile
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
```

### Docker Usage

Build the image

```sh
docker build django_dx
```

Run the image

```sh
docker run --rm -it -p 8000:8000 django_dx
```

### Docker Tips: Development

I mostly use this Dockerfile for production but I occasionnaly build/run the image on my development environment to test the image. It's a useful way to replicate the production runtime on my desktop.

### Docker Tips: Production

I use Github Actions to build and push the docker image to Github's Container registry. Then, I fetch and run the image on my production setup.

## Dependabot

Dependabot keeps my dependencies up to date. It opens a PR on Github when a dependecy updates.

### Dependabot Installation

Create the file `.github/dependabot.yml` at the root of your project.

```yml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: weekly
      time: "07:00"
      
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: weekly
      time: "07:00"
```

This will adds dependabot for Poetry (via pip ecosystem) and also any dependencies in your Github Actions.

## Github Actions

These actions automate testing, linting and publishing code commited to git.

### Github Actions : Linting

This workflow ensure the code is linted correctly with `Pylint` on each push.

```yml
name: linter

on:
  push:
    paths-ignore:
      - '**/README.md'

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - name: Install poetry
        run: |
          curl -sSL https://install.python-poetry.org | python - --version 1.2.0
          echo "PATH=${HOME}/.local/bin:${PATH}" >> $GITHUB_ENV
      - uses: actions/setup-python@v4
        with:
          cache: 'poetry'
      - run: poetry install
      - name: Run Tests
        run: poetry run pylint **/*.py
```

### Github Actions : Continuous Integration

This workflow ensure the test suite passes on every push.

```yml
name: tests

on:
  push:
    paths-ignore:
      - '**/README.md'

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres
        env:
          POSTGRES_USER: django_dx
          POSTGRES_PASSWORD: django_dx
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
        ports:
          - 5432:5432
      redis:
        image: redis
        options: --health-cmd "redis-cli ping" --health-interval 10s --health-timeout 5s --health-retries 5
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v3
      - name: Install poetry
        run: |
          curl -sSL https://install.python-poetry.org | python - --version 1.2.0
          echo "PATH=${HOME}/.local/bin:${PATH}" >> $GITHUB_ENV
      - uses: actions/setup-python@v4
        with:
          cache: 'poetry'
      - run: poetry install
      - name: Run Tests
        run: poetry run pytest
```

### Github Actions : Continuous Deployment

This workflow creates and publish the production Docker image to the Github's Container registry.

```yml
name: Create and publish a Docker image

on:
  push:
    branches: ['main']
    paths-ignore:
      - '**/README.md'
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push-image:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Log in to the Container registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v3
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```
