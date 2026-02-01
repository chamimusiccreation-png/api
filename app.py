from flask import Flask, request, jsonify
from flask_cors import CORS
import yt_dlp
import os

app = Flask(__name__)
CORS(app) # ඕනම තැනක ඉඳන් request එවන්න පුළුවන් වෙන්න

@app.route('/')
def home():
    return "Nani's YT Downloader API is Running! 🚀"

@app.route('/api/download', methods=['GET'])
def get_video_info():
    video_url = request.args.get('url')

    if not video_url:
        return jsonify({"error": "No URL provided"}), 400

    # yt-dlp options
    ydl_opts = {
        'format': 'best',
        'noplaylist': True,
        'quiet': True,
        # cookies.txt ෆයිල් එක තියෙනවා නම් පාවිච්චි කරන්න
        'cookiefile': 'cookies.txt' if os.path.exists('cookies.txt') else None
    }

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # Video info ගන්නවා (Download කරන්නේ නෑ)
            info = ydl.extract_info(video_url, download=False)
            
            return jsonify({
                "status": "success",
                "title": info.get('title'),
                "duration": info.get('duration'),
                "thumbnail": info.get('thumbnail'),
                "direct_url": info.get('url'), # මේක තමයි වීඩියෝ ලින්ක් එක
                "format_note": info.get('format_note')
            })

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
