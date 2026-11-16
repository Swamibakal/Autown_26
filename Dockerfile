# Step 1: build the Flutter website
FROM ghcr.io/cirruslabs/flutter:stable AS web
WORKDIR /app/frontend
COPY frontend/ .
RUN flutter create . --platforms web && flutter pub get && flutter build web --release

# Step 2: run the Python backend, which also serves the website
FROM python:3.12-slim
WORKDIR /app
COPY backend/ backend/
RUN pip install --no-cache-dir -r backend/requirements.txt
COPY --from=web /app/frontend/build/web frontend/build/web
WORKDIR /app/backend
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
