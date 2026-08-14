# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app

# Copy only package files first — this layer only rebuilds when dependencies change
COPY app/package*.json ./
RUN npm ci --omit=dev

# Now copy the rest of the source code
COPY app/ ./

# Stage 2: Production image (smaller, no build tools)
FROM node:20-alpine
WORKDIR /app

# Create a non-root user for security best practice
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app ./

USER appuser

EXPOSE 3000

# Basic container-level health check
HEALTHCHECK --interval=30s --timeout=3s CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "index.js"]