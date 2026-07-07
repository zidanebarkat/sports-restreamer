#!/bin/bash
SPORTS_URL="${SPORTS_URL:-https://hello.1yallashoot.com/splayer/Live1.php}"
OUTPUT_URL="${OUTPUT_URL:-}"

echo "[sports] Starting..."
echo "[sports] SPORTS_URL=$SPORTS_URL"

[ -z "$OUTPUT_URL" ] && { echo "Missing OUTPUT_URL"; exit 1; }

extract_m3u8() {
    local embed_urls
    embed_urls=$(curl -sL "$SPORTS_URL" 2>/dev/null | grep -oP 'https://player\.simokora\.com/embed\.php\?stream=[^"'"'"'&]+' | sort -u)
    [ -z "$embed_urls" ] && return 1
    while IFS= read -r embed; do
        [ -z "$embed" ] && continue
        local m3u8
        m3u8=$(curl -sL -H "Referer: $SPORTS_URL" -H "User-Agent: Mozilla/5.0" "$embed" 2>/dev/null | grep -oP 'https?://[^"'"'"'<>]+\.m3u8[^"'"'"'<>]*' | head -1)
        if [ -n "$m3u8" ]; then
            echo "$m3u8"
            return 0
        fi
    done <<< "$embed_urls"
    return 1
}

while true; do
    echo "[sports] Extracting m3u8 URL..."
    m3u8_url=$(extract_m3u8)
    if [ -z "$m3u8_url" ]; then
        echo "[sports] Failed to extract m3u8, retrying in 10s..."
        sleep 10
        continue
    fi
    echo "[sports] Got m3u8: ${m3u8_url:0:80}..."

    echo "[sports] Starting ffmpeg..."
    ffmpeg -nostdin -re -timeout 15000000 -analyzeduration 10M -probesize 10M \
        -headers "Referer: https://player.simokora.com/\r\nUser-Agent: Mozilla/5.0\r\n" \
        -protocol_whitelist "file,http,https,tcp,tls,crypto" \
        -fflags +discardcorrupt \
        -max_reload 999 \
        -i "$m3u8_url" \
        -c copy \
        -f flv "$OUTPUT_URL" \
        -loglevel warning -stats 2>&1 </dev/null

    echo "[sports] Stream ended, re-extracting..."
    sleep 2
done
