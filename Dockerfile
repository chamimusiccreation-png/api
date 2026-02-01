# Python පොඩි version එකක් ගමු
FROM python:3.9-slim

# Working directory එක හදමු
WORKDIR /app

# Dependencies install කරගමු
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Server එකට අවශ්‍ය file ටික copy කරමු
COPY . .

# Flask run කරමු (Port 8000)
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
