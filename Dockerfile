# Build stage
FROM swift:5.9-jammy as build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY Package.swift Package.resolved* ./

# Fetch dependencies
RUN swift package resolve

# Copy source code
COPY Sources ./Sources
COPY Tests ./Tests

# Build for release
RUN swift build -c release

# Build tests
RUN swift build --build-tests

# Runtime stage
FROM swift:5.9-jammy-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1001 -s /bin/bash swift

# Set working directory
WORKDIR /app

# Copy built executables
COPY --from=build /app/.build/release/xai-cli /usr/local/bin/xai-cli

# Copy the entire build directory for testing
COPY --from=build --chown=swift:swift /app /app

# Switch to non-root user
USER swift

# Set environment variable for API key (to be overridden at runtime)
ENV XAI_API_KEY=""

# Default command
CMD ["xai-cli", "--help"]