FROM node:20 AS builder
WORKDIR /build

# 1. Build SDK (uses pre-installed yarn v1)
COPY ./protocol-v2/sdk ./protocol-v2/sdk
WORKDIR /build/protocol-v2/sdk
RUN yarn install --ignore-engines && yarn build

# 2. Copy frontend workspace files
WORKDIR /build/app
COPY ./drift-frontend/package.json .
COPY ./drift-frontend/.yarnrc.yml .
COPY ./drift-frontend/ui ./ui

# Yarn Berry (v3) is required by the packageManager field
RUN corepack enable && corepack prepare yarn@3.6.4 --activate && yarn install

# NEXT_PUBLIC_ env vars are baked at build time.
# Override these at docker build to set external-facing DLOB URLs.
ARG NEXT_PUBLIC_DLOB_HTTP_URL=http://localhost:6969
ARG NEXT_PUBLIC_DLOB_WS_URL=ws://localhost:6970/ws
ARG NEXT_PUBLIC_SOLANA_DEVNET_RPC_ENDPOINT=https://api.devnet.solana.com
ENV NEXT_PUBLIC_DLOB_HTTP_URL=$NEXT_PUBLIC_DLOB_HTTP_URL
ENV NEXT_PUBLIC_DLOB_WS_URL=$NEXT_PUBLIC_DLOB_WS_URL
ENV NEXT_PUBLIC_SOLANA_DEVNET_RPC_ENDPOINT=$NEXT_PUBLIC_SOLANA_DEVNET_RPC_ENDPOINT

# Build Next.js (uses webpack, not turbopack)
WORKDIR /build/app/ui
RUN yarn build

# Runtime image
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /build/app/ui/.next ./.next
COPY --from=builder /build/app/ui/public ./public
COPY --from=builder /build/app/ui/node_modules ./node_modules
COPY --from=builder /build/app/ui/package.json .

EXPOSE 3000
CMD ["node_modules/.bin/next", "start"]
