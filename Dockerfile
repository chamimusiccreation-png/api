# Stage 1: Build the Rust App
# වෙනස: 1.75 වෙනුවට 'latest' පාවිච්චි කරමු.
FROM rust:latest as builder

WORKDIR /usr/src/app

# කලින් වගේම ෆයිල් කොපි කරගන්නවා
COPY . .

# Build කරනවා (දැන් අලුත් version එක නිසා error එන්නේ නෑ)
RUN cargo install --path .

# Stage 2: Runtime Environment (මේක වෙනස් වෙන්නේ නෑ)
FROM python:3.11-slim-bookworm

# 1. System dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. yt-dlp install (Python pip හරහා)
RUN pip install --no-cache-dir yt-dlp

# 3. Rust app එක copy කරගන්නවා
COPY --from=builder /usr/local/cargo/bin/yt_api_rust /usr/local/bin/yt_api_rust

# 4. Port එක set කරනවා (Optional but good for documentation)
ENV PORT=8000

# 5. වැඩ පටන් ගමු
CMD ["yt_api_rust"]
