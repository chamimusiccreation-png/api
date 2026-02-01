# Stage 1: Build the Rust App
FROM rust:1.75-slim-bookworm as builder
WORKDIR /usr/src/app
COPY . .
RUN cargo install --path .

# Stage 2: Runtime Environment (මේක තමයි ඇත්තටම run වෙන්නේ)
FROM python:3.11-slim-bookworm

# 1. System dependencies දාගමු (yt-dlp එකට ඕන ඒවා)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. yt-dlp install කරමු (Python pip හරහා)
RUN pip install --no-cache-dir yt-dlp

# 3. කලින් Build කරපු Rust app එක මෙහාට copy කරගමු
COPY --from=builder /usr/local/cargo/bin/yt_api_rust /usr/local/bin/yt_api_rust

# 4. වැඩ පටන් ගමු
CMD ["yt_api_rust"]
