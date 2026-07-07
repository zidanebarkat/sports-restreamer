#!/bin/bash
M3U8_URL="${M3U8_URL:-https://2.simokora.com/my-hls/h9asfma10d5.m3u8}"
OUTPUT_URL="${OUTPUT_URL:-rtmps://a.rtmp.youtube.com:443/live2/ru33-pe6q-z9gr-a2es-5t82}"

echo "[sports] Starting..."
echo "[sports] M3U8_URL=$M3U8_URL"

[ -z "$OUTPUT_URL" ] && { echo "Missing OUTPUT_URL"; exit 1; }

while true; do
    echo "[sports] Starting ffmpeg..."

    ffmpeg -nostdin -re \
        -headers "Referer: https://zidanebarkat.github.io/sport24wire-player/\r\nUser-Agent: Mozilla/5.0\r\n" \
        -protocol_whitelist "file,http,https,tcp,tls,crypto" \
        -fflags +discardcorrupt \
        -timeout 30000000 \
        -i "$M3U8_URL" \
        -filter_complex "[0:v]scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2[vid]; \
                         color=c=black:s=1280x720:r=30,format=rgba[c]; \
                         [c]drawtext=text='FOOT WC 26':fontsize=64:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2[overlay]; \
                         [vid][overlay]overlay=shortest=1:enable='between(mod(t,300),0,15)'" \
        -c:v libx264 -preset ultrafast -b:v 1500k -maxrate 2000k -bufsize 3000k -r 10 -g 30 \
        -c:a aac -b:a 128k \
        -rtmp_live live \
        -f flv "$OUTPUT_URL" \
        -loglevel warning -stats 2>&1 </dev/null

    echo "[sports] Stream ended, restarting in 5s..."
    sleep 5
done
