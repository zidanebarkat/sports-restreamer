#!/bin/bash
M3U8_URL="${M3U8_URL:-http://d0cf70eb.rostelekom.xyz/iptv/PMRVKVATL4XX98/19062/index.m3u8}"
OUTPUT_URL="${OUTPUT_URL:-rtmps://a.rtmp.youtube.com:443/live2/ru33-pe6q-z9gr-a2es-5t82}"

echo "[sports] Starting..."
echo "[sports] M3U8_URL=$M3U8_URL"

[ -z "$OUTPUT_URL" ] && { echo "Missing OUTPUT_URL"; exit 1; }

while true; do
    echo "[sports] Starting ffmpeg..."
    ffmpeg -nostdin -re \
        -user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        -referer "https://hello.1yallashoot.com/" \
        -protocol_whitelist "file,http,https,tcp,tls,crypto" \
        -fflags +discardcorrupt \
        -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 60 \
        -timeout 30000000 \
        -i "$M3U8_URL" \
        -c:v copy \
        -c:a copy \
        -rtmp_live live \
        -f flv "$OUTPUT_URL" \
        -loglevel warning -stats 2>&1 </dev/null

    echo "[sports] Stream ended, restarting in 5s..."
    sleep 5
done
