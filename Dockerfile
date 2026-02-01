FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# මෙතන PORT එක දෙන එක වැදගත් නැහැ, Koyeb එකෙන් environment variable එකක් විදිහට දෙනවා.
# හැබැයි අපි Gunicorn command එක හරියට දෙන්න ඕන.
CMD gunicorn -b 0.0.0.0:8000 app:app
