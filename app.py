import os
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS
import yt_dlp

# Logging සෙට් කරගමු (Koyeb Logs වල error බලාගන්න ලේසියි)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# --- 1. HEALTH CHECK ROUTE (වැදගත්ම එක) ---
# Koyeb එකෙන් බලන්නේ මේක විතරයි. මේක ඉක්මනට 200 OK දෙන්න ඕන.
@app.route('/')
def health_check():
    return jsonify({
        "status": "healthy",
        "message": "Server is running smoothly! 🚀"
    }), 200

# --- 2. DOWNLOAD API ROUTE ---
@app.route('/api/download', methods=['GET'])
def get_video_info():
    video_url = request.args.get('url')

    if not video_url:
        return jsonify({"error": "No URL provided"}), 400

    logger.info(f"Processing URL: {video_url}")

    # Cookies file එක තියෙනවද බලනවා
    cookies_path = 'cookies.txt'
    has_cookies = os.path.exists(cookies_path)
    
    ydl_opts = {
        'format': 'best',
        'noplaylist': True,
        'quiet': True,
        'no_warnings': True,
        # Cookies තියෙනවා නම් විතරක් පාවිච්චි කරන්න
        'cookiefile': cookies_path if has_cookies else None,
        # Server එකේදි උදව් වෙන අමතර settings
        'geo_bypass': True,
        'nocheckcertificate': True,
    }

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # Video Info ගන්නවා (Download කරන්නේ නෑ)
            info = ydl.extract_info(video_url, download=False)
            
            # Direct URL එක ගන්නවා
            direct_url = info.get('url')
            
            return jsonify({
                "status": "success",
                "title": info.get('title'),
                "duration": info.get('duration'),
                "thumbnail": info.get('thumbnail'),
                "direct_url": direct_url,
                "used_cookies": has_cookies
            })

    except Exception as e:
        logger.error(f"Error fetching video: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500

# --- SERVER STARTUP ---
if __name__ == '__main__':
    # Koyeb එකෙන් දෙන PORT එක ගන්නවා. නැත්නම් 8000 ගන්නවා.
    port = int(os.environ.get("PORT", 8000))
    app.run(host='0.0.0.0', port=port)
