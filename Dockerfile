FROM evoapicloud/evolution-api:v2.3.7

# Expose the port the upstream image uses (container listens on 8080)
EXPOSE 8080

# Create volume directories if they don't exist
RUN mkdir -p /evolution/instances

# Set default environment variables (minimal configuration, no cache)
# SERVER_URL and AUTHENTICATION_API_KEY must be set via dokku config:set
ENV DEL_INSTANCE=false \
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
    CACHE_LOCAL_ENABLED=false

# Reuse base image ENTRYPOINT/CMD so behavior remains identical