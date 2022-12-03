# django_dx

This repository is my version of Django Cookie Cutter with all the things that I setup for most of my Django projects

- [pyenv](https://github.com/pyenv/pyenv) Manage Python versions
- [poetry](https://python-poetry.org/) Manage Python dependencies
- [Django](https://www.djangoproject.com/) An awesome Web Framework
- [Git](https://git-scm.com/) Source Control
- [pylint](https://pylint.pycqa.org/en/latest/) Static code analyzer, enforces best practices and python standards
- [isort](https://pycqa.github.io/isort/) isort your imports, so you don't have to.
- [python-dotenv](https://saurabh-kumar.com/python-dotenv/) Reads from `.env` and sets them as environnement variables
- [pytest](https://docs.pytest.org/) Unit test framework that improves on Python's unittest library
- [Gunicorn](https://gunicorn.org/) Production Ready WSGI HTTP Server
- [Celery](https://docs.celeryq.dev/) Asynchronous task queue
- [Docker](https://www.docker.com/) OS-level virtualization to deliver software in packages called containers
- [Docker Compose](https://docs.docker.com/compose/) A tool for defining and running multi-container Docker applications
- [Postgres](https://www.postgresql.org/) Relational database management system
- [Redis](https://redis.io/) In-memory data structure store
- [Django’s cache framework](https://docs.djangoproject.com/en/dev/topics/cache/#django-s-cache-framework) Save dynamic pages so they don’t have to be calculated for each request
- [Adminer](https://www.adminer.org/) A tool for managing content in databases
- [Github Actions](https://github.com/features/actions) A (CI/CD) platform
- [Dependabot](https://github.com/dependabot) Automated dependency updates built into GitHub

## Pyenv

[pyenv](https://github.com/pyenv/pyenv) allows to manage multiple python version. This is useful when you are working on multiple Django application over the time. It also make sure everyone working on the project uses the same python version.

### Installation

```sh
brew install pyenv
```

There's a few post-installation steps, I use **zsh** :

```sh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

### Usage

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

### Installation

```sh
curl -sSL https://install.python-poetry.org | python3 -
```

There's a post-installation step, I use **zsh** :

```
poetry completions zsh > ~/.zfunc/_poetry`
```

### Usage

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

### VSCode integration

VSCode should detect poetry environment automatically. It will provide autocompletion and source code links. You might need to select it with `Select python interpreter` command.

## Pylint

[pylint](https://pylint.pycqa.org/en/latest/) is a static code analyzer that helps you enforce best practices and python standards. 

### Installation

I'm using the `pylint-django` plugin that includes a dependency on pylint. It adds some configuration options for Django projects.

```sh
poetry add -D pylint-django
```

Create `.pylintrc` file at the root of your project

```sh
[MASTER]
load-plugins=pylint_django, pylint_django.checkers.migrations
django-settings-module=django_dx.settings

[FORMAT]
max-line-length=120

[MESSAGES CONTROL]
disable=missing-docstring
```

Change **django_dx.settings** for your project settings.py path

### VSCode integration

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

### VSCode integration

VSCode can sort your import with the `Python Refactor: Sort Imports` command.

```json
# .vscode/settings.json
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

### VSCode integration

Like the other tools, it's dierctly integrated with VSCode and you just need to turn it on. I only change the max-line-length to 120 because I find the default (80) to small.

```json
# .vscode/settings.json
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

## Installation

```sh
poetry add python-dotenv
```

### Usage

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
