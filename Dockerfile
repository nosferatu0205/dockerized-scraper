# Use Node.js 20 Alpine for performance
FROM node:20-alpine

# Install essential dependencies for Puppeteer - minimal but complete setup
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    && rm -rf /var/cache/apk/*

# Tell Puppeteer to use installed Chromium and set Chrome flags
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/bin/chromium-browser \
    DISPLAY=:99

WORKDIR /app

# Copy package.json only first (for better caching)
COPY package.json ./

# Use npm install instead of npm ci (since no lock file)
RUN npm install --production

# Copy application files
COPY . .

# Create directories
RUN mkdir -p /app/output /app/config

# Run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

CMD ["node", "parallelArchiveScraper.js"]