FROM    alpine:latest

RUN     apk add --no-cache --update ffmpeg bash && rm -rf /var/cache/apk/*
COPY    ./entrypoint.sh /caesiumbin/entrypoint.sh
RUN     chmod +x /caesiumbin/entrypoint.sh

ENTRYPOINT  ["/caesiumbin/entrypoint.sh",""]
