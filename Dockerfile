FROM python:3.8.10-alpine
WORKDIR /code

RUN apk add --update --no-cache --virtual .build-deps \
    gcc musl-dev libffi-dev curl \
    && curl -sSL https://install.python-poetry.org | python3 - --version 1.2.0 \
    && apk del --no-cache .build-deps \
    && apk add zip

ENV PATH=/root/.local/bin:$PATH
COPY pyproject.toml /code
COPY poetry.toml /code
RUN poetry install --without dev
RUN mkdir -p python
RUN cp -R .venv/lib python
RUN zip -r lib_dependencies.zip python
CMD tail -f /dev/null
