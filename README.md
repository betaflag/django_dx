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
