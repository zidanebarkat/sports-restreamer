#!/bin/bash
M3U8_URL="${M3U8_URL:-https://2.simokora.com/my-hls/h9asfma10d5.m3u8}"
OUTPUT_URL="${OUTPUT_URL:-rtmps://a.rtmp.youtube.com:443/live2/ru33-pe6q-z9gr-a2es-5t82}"

echo "[sports] Starting..."
echo "[sports] M3U8_URL=$M3U8_URL"

[ -z "$OUTPUT_URL" ] && { echo "Missing OUTPUT_URL"; exit 1; }

while true; do
    echo "[sports] Starting ffmpeg..."

    ffmpeg -nostdin -re \
        -user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        -referer "https://zidanebarkat.github.io/sport24wire-player/" \
        -headers "Origin: https://zidanebarkat.github.io\r\n" \
        -protocol_whitelist "file,http,https,tcp,tls,crypto" \
        -fflags +discardcorrupt \
        -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 60 \
        -timeout 30000000 \
        -i "$M3U8_URL" \
        -filter_complex "[0:v]scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2[vid]; \
                         color=c=black:s=1280x720:r=30,format=rgba[c]; \
                         [c]drawtext=text='FOOT WC 26':fontsize=64:fontcolor=white:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:x=(w-text_w)/2:y=(h-text_h)/2[overlay]; \
                         [vid][overlay]overlay=shortest=1:enable='between(mod(t,300),0,15)'" \
        -c:v libx264 -preset ultrafast -b:v 1500k -maxrate 2000k -bufsize 3000k -r 10 -g 30 \
        -c:a aac -b:a 128k \
        -rtmp_live live \
        -f flv "$OUTPUT_URL" \
        -loglevel warning -stats 2>&1 </dev/null

    echo "[sports] Stream ended, restarting in 5s..."
    sleep 5
done
