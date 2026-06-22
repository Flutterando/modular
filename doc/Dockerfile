# syntax=docker/dockerfile:1

# Modular documentation site (Docusaurus 3) — built once, served as static files.

# ---- Build stage: compile the Docusaurus static site ----------------------
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies first so this layer is cached unless the lockfile changes.
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Build the static site into /app/build.
COPY . .
RUN yarn build

# ---- Runtime stage: serve the static output with nginx --------------------
FROM nginx:1.27-alpine AS runtime

# Clean-URL / caching config (Docusaurus emits per-route folders + a 404.html).
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Static build output from the build stage.
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
