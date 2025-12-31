FROM atendai/evolution-api:v2.2.0

# Expose the port the upstream image uses (container listens on 8080)
EXPOSE 8080

# Create volume directories if they don't exist
RUN mkdir -p /evolution/instances

# Health check to ensure the service is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1

# Reuse base image ENTRYPOINT/CMD so behavior remains identical