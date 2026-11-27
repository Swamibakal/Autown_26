# Step 1: build the Flutter website
FROM ghcr.io/cirruslabs/flutter:stable AS web
WORKDIR /app/frontend
COPY frontend/ .
RUN flutter create . --platforms web && flutter pub get && flutter build web --release

# Step 2: serve the built website as static files (no backend server)
FROM nginx:alpine
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY security-headers.conf /etc/nginx/snippets/security-headers.conf
COPY --from=web /app/frontend/build/web /usr/share/nginx/html
# Render sets PORT automatically; 8080 is used when running elsewhere.
ENV PORT=8080
