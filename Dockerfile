FROM python:3.11.4-alpine3.17 as builder

ARG POETRY_VIRTUALENVS_CREATE="true"

ENV POETRY_HOME="/app/.poetry" \
    POETRY_VERSION="1.5.1" \
    POETRY_VIRTUALENVS_CREATE="${POETRY_VIRTUALENVS_CREATE}"

RUN apk add --update bash curl openssl libstdc++ proj-util \ 
    && pip3 install pip --no-cache-dir --upgrade pip \
                                                 cython \
                                                 virtualenv \ 
                                                 setuptools \
                                                 supervisor \
    && curl -sSL https://install.python-poetry.org | POETRY_HOME="${POETRY_HOME}" POETRY_VERSION=${POETRY_VERSION} python3 - \
    && adduser --disabled-password --home /app python \
    && chown -R python.python /app \
    && curl -o /opt/entrypoint.sh https://raw.githubusercontent.com/deepnox-io/docker-entrypoints/main/python-poetry-entrypoint.sh \
    && chmod +x /opt/*.sh \
    && rm -rf .build-deps \
              /tmp/* \
              /var/cache/apk/*

FROM scratch

ARG POETRY_VIRTUALENVS_CREATE="true"

ENV POETRY_HOME="/app/.poetry"
ENV POETRY_CACHE_DIR="${POETRY_HOME}/cache" \
    POETRY_VIRTUALENVS_PATH="${POETRY_HOME}/venv" \
    POETRY_VIRTUALENVS_CREATE="${POETRY_VIRTUALENVS_CREATE}" \
    PATH="/app/.poetry/bin:${PATH}"

COPY --from=builder ["/", "/"]

USER python
WORKDIR "/app"

ENTRYPOINT ["/opt/entrypoint.sh"]

CMD ["python3"]
