FROM alpine:3.20

RUN apk add --no-cache ffmpeg python3 py3-pip py3-flask yt-dlp curl bash fontconfig ttf-dejavu

RUN echo "cachebust-20260707-v2"
COPY restream.sh /restream.sh
COPY app.py /app.py

RUN chmod +x /restream.sh

CMD ["python3", "/app.py"]
