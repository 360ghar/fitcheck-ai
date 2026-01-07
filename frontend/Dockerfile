# FitCheck AI Frontend Dockerfile
# Multi-stage build: Node builder + Nginx server

# Stage 1: Builder - Build React application
FROM node:18-alpine as builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Server - Serve with Nginx
FROM nginx:alpine

# Add labels for metadata
LABEL maintainer="FitCheck AI"
LABEL description="FitCheck AI Frontend - React + Vite + Nginx"

# Copy built assets from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Create non-root user (alpine nginx runs as root by default)
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G nginx-app -g nginx-app nginx-app && \
    chown -R nginx-app:nginx-app /usr/share/nginx/html && \
    chown -R nginx-app:nginx-app /var/cache/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    chown -R nginx-app:nginx-app /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /etc/nginx/nginx.conf

# Switch user (nginx alpine needs special handling)
USER nginx-app

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx (need to be root for nginx command in alpine)
USER root
CMD ["nginx", "-g", "daemon off;"]
