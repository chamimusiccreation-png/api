# 1. Debian වෙනුවට Alpine ගන්නවා (මේක ඉතාම පොඩියි, වේගවත්)
FROM node:18-alpine

# 2. System updates සහ අවශ්‍ය Tools දාගන්නවා
# apk add කියන්නේ Alpine වල install කරන ක්‍රමය. මේක පට්ට fast.
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg

# 3. yt-dlp install කරගන්නවා
RUN pip3 install yt-dlp --break-system-packages

# 4. App directory එක හදනවා
WORKDIR /app

# 5. Dependencies install කරනවා
COPY package.json .
RUN npm install

# 6. ෆයිල් ටික copy කරනවා
COPY . .

# 7. Port එක set කරනවා
ENV PORT=8000

# 8. Server එක start කරනවා
CMD ["node", "index.js"]
