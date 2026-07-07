FROM alpine:3.19
RUN apk add --no-cache ffmpeg python3 py3-pip curl
RUN pip3 install flask yt-dlp
COPY app.py /app.py
COPY restream.sh /restream.sh
RUN chmod +x /restream.sh
CMD ["python3", "/app.py"]
