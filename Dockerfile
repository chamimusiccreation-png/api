# Stage 1: Build the Rust App
# වෙනස: 'latest' වෙනුවට '1-bookworm' දානවා. 
# එතකොට Runtime එකයි Build එකයි දෙකම එකම OS (Debian Bookworm).
FROM rust:1-bookworm as builder

WORKDIR /usr/src/app
COPY . .
RUN cargo install --path .

# Stage 2: Runtime Environment
# මේකත් Bookworm නිසා දැන් ප්‍රශ්නයක් නෑ.
FROM python:3.11-slim-bookworm

# 1. System dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. yt-dlp install
RUN pip install --no-cache-dir yt-dlp

# 3. Copy binary
COPY --from=builder /usr/local/cargo/bin/yt_api_rust /usr/local/bin/yt_api_rust

ENV PORT=8000

# 4. Start
CMD ["yt_api_rust"]
