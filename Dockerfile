# Node.js 18 පාවිච්චි කරමු (Stable)
FROM node:18-bullseye-slim

# අපිට System එකට Python සහ ffmpeg දාගන්න වෙනවා (yt-dlp දුවන්න)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# yt-dlp එක pip හරහා install කරගමු
# --break-system-packages දාන්නේ අලුත් Python version වල අවුලක් එන නිසා
RUN pip3 install yt-dlp --break-system-packages

# App එකේ ෆයිල් දාන්න තැනක් හදාගමු
WORKDIR /app

# Dependencies install කරමු
COPY package.json .
RUN npm install

# ඉතුරු ෆයිල් ටික copy කරමු
COPY . .

# Port එක 8000
ENV PORT=8000

# Server එක start කරමු
CMD ["node", "index.js"]
