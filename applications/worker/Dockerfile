FROM python:3.10-buster

RUN pip install poetry

# Copy all source files
COPY poetry.lock .
COPY pyproject.toml .
COPY README.md .
ADD worker worker
ADD tests tests

RUN poetry install

CMD ["poetry", "run", "temporal-worker"]
