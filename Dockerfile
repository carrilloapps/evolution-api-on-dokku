FROM evoapicloud/evolution-api:v2.3.7

# Expose the port the upstream image uses (container listens on 8080)
EXPOSE 8080

# Create volume directories if they don't exist
RUN mkdir -p /evolution/instances

# Set default environment variables (Redis/Cache disabled, only PostgreSQL)
ENV SERVER_URL=http://localhost:8080 \
    DEL_INSTANCE=false \
    DATABASE_ENABLED=true \
    DATABASE_PROVIDER=postgresql \
    DATABASE_CONNECTION_CLIENT_NAME=evolution_exchange \
    DATABASE_SAVE_DATA_INSTANCE=true \
    DATABASE_SAVE_DATA_NEW_MESSAGE=true \
    DATABASE_SAVE_MESSAGE_UPDATE=true \
    DATABASE_SAVE_DATA_CONTACTS=true \
    DATABASE_SAVE_DATA_CHATS=true \
    DATABASE_SAVE_DATA_LABELS=true \
    DATABASE_SAVE_DATA_HISTORIC=true \
    CACHE_REDIS_ENABLED=false \
    CACHE_REDIS_URI="" \
    CACHE_LOCAL_ENABLED=false \
    CONFIG_SESSION_PHONE_VERSION=2.3000.1031543708 \
    CONFIG_SESSION_PHONE_CLIENT=carrilloapps \
    CONFIG_SESSION_PHONE_NAME=Chrome

# Health check to ensure the service is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1

# Reuse base image ENTRYPOINT/CMD so behavior remains identical