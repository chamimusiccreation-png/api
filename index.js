const express = require('express');
const cors = require('cors');
const { exec } = require('child_process');

const app = express();
const PORT = process.env.PORT || 8000;

app.use(cors());

// 1. Health Check (Koyeb එකට ඕනම එක)
app.get('/', (req, res) => {
    res.status(200).send("Node.js Server is Running! 🚀");
});

// 2. Download API
app.get('/api/download', (req, res) => {
    const videoUrl = req.query.url;

    if (!videoUrl) {
        return res.status(400).json({ error: "No URL provided" });
    }

    console.log(`Processing: ${videoUrl}`);

    // yt-dlp command එක run කරනවා
    // -j = JSON output
    // -f best = හොඳම quality එක
    const command = `yt_dlp -j --no-playlist --quiet "${videoUrl}"`;

    exec(command, { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error.message}`);
            return res.status(500).json({ error: "Download failed", details: stderr });
        }

        try {
            const info = JSON.parse(stdout);
            
            // අපිට ඕන ටික විතරක් යවමු
            const responseData = {
                status: "success",
                title: info.title,
                duration: info.duration,
                thumbnail: info.thumbnail,
                direct_url: info.url, // මේක තමයි ලින්ක් එක
                format: info.format
            };

            res.json(responseData);

        } catch (parseError) {
            res.status(500).json({ error: "Failed to parse JSON" });
        }
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});
