# ─────────────────────────────────────────────
# STAGE 1: Build dependencies
# ─────────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

# ─────────────────────────────────────────────
# STAGE 2: Production image
# ─────────────────────────────────────────────
FROM node:18-alpine

WORKDIR /app

# Copy only required files from builder
COPY --from=builder /app /app

EXPOSE 3000

CMD ["node", "server.js"]