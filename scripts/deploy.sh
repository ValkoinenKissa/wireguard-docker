#!/usr/bin/env bash

echo "[INFO] Validating Docker Compose configuration..."

docker compose config --quiet

echo "[INFO] Pulling images..."

docker compose pull

echo "[INFO] Starting services..."

docker compose up -d

echo "[INFO] Deployment completed."

docker compose ps