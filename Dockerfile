FROM        alpine:latest

RUN         apk add --no-cache --update ffmpeg bash && rm -rf /var/cache/apk/*
COPY        ./entrypoint.sh /bin/entrypoint.sh
RUN         chmod +x /bin/entrypoint.sh

COPY        ./src /app/src
WORKDIR     /video
ENTRYPOINT  ["/bin/entrypoint.sh",""]
