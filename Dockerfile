FROM node:22-bullseye-slim

USER root

ARG N8N_PATH=/usr/local/lib/node_modules/n8n
ARG BASE_PATH=/home/nodejs/.n8n
ARG DATABASE_PATH=$BASE_PATH/database
ARG CONFIG_PATH=$BASE_PATH/config
ARG WORKFLOWS_PATH=$BASE_PATH/workflows
ARG LOGS_PATH=$BASE_PATH/logs
ARG N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=$N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS
ARG allowVulnerableTags=true
ARG N8N_HOST=0.0.0.0
ARG N8N_PORT=7860
ARG N8N_PROTOCOL=https
ARG N8N_EDITOR_BASE_URL=$N8N_EDITOR_BASE_URL
ARG WEBHOOK_URL=$WEBHOOK_URL
ARG GENERIC_TIMEZONE=$GENERIC_TIMEZONE
ARG TZ=$TZ
ARG N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY
ARG DB_TYPE=$DB_TYPE
ARG DB_POSTGRESDB_SCHEMA=$DB_POSTGRESDB_SCHEMA
ARG DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST
ARG DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE
ARG DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT
ARG DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER
ARG DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD
ARG NODE_FUNCTION_ALLOW_BUILTIN=*
ARG NODE_FUNCTION_ALLOW_EXTERNAL=*

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    python3-venv \
    make \
    g++ \
    build-essential \
    libcairo2-dev \
    libpango1.0-dev \
    chromium \
    postgresql-client \
    curl \
    tini \
 && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=7860 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    NODE_FUNCTION_ALLOW_BUILTIN=* \
    NODE_FUNCTION_ALLOW_EXTERNAL=*

RUN npm install -g n8n@2.35.3 --no-audit --no-fund --loglevel=error

RUN cd /usr/local/lib/node_modules/n8n && \
    npm rebuild sqlite3 --build-from-source 2>/dev/null || true && \
    if [ -d "node_modules/isolated-vm" ]; then \
        cd node_modules/isolated-vm && \
        npx --yes node-gyp rebuild --release 2>/dev/null || true; \
    fi

RUN python3 -m venv /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner/.venv \
    && /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner/.venv/bin/pip install --upgrade pip 2>/dev/null || true

RUN groupadd -g 1001 -r nodejs \
    && useradd -u 1001 -r -g nodejs -d /home/nodejs nodejs \
    && mkdir -p /home/nodejs/.n8n \
    && chmod -R 755 /home/nodejs \
    && chown -R nodejs:nodejs /home/nodejs \
    && chown -R nodejs:nodejs /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner/.venv 2>/dev/null || true

USER nodejs

WORKDIR /home/nodejs

EXPOSE 7860

ENTRYPOINT ["tini", "--"]
CMD ["n8n", "start"]
