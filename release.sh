#!/bin/bash
# Release script ejecutado automáticamente por Dokku después del build

set -e

echo "-----> Running Evolution API release tasks"

# Configurar DATABASE_CONNECTION_URI si DATABASE_URL existe
if [ ! -z "$DATABASE_URL" ]; then
    export DATABASE_CONNECTION_URI="$DATABASE_URL"
    echo "DATABASE_CONNECTION_URI configured from DATABASE_URL"
fi

echo "-----> Release tasks completed"
