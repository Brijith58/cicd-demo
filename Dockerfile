# ─────────────────────────────────────────────
# Stage 1: Use official Node.js LTS base image
# ─────────────────────────────────────────────
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package files first (better Docker layer caching)
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy the rest of the application source code
COPY . .

# Expose the port the app listens on
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production

# Healthcheck — Docker will ping /health every 30s
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Command to start the application
CMD ["node", "app.js"]
