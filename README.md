[![](https://images.microbadger.com/badges/version/majamee/hero-videoptim.svg)](https://microbadger.com/images/majamee/hero-videoptim) [![](https://images.microbadger.com/badges/image/majamee/hero-videoptim.svg)](https://microbadger.com/images/majamee/hero-videoptim) | 
[![Docker Automated build](https://img.shields.io/docker/automated/majamee/hero-videoptim.svg)]() [![Docker Build Status](https://img.shields.io/docker/build/majamee/hero-videoptim.svg)]() | 
[![Docker Stars](https://img.shields.io/docker/stars/majamee/hero-videoptim.svg?style=social)]() [![Docker Pulls](https://img.shields.io/docker/pulls/majamee/hero-videoptim.svg?style=social)]()

# hero-videoptim
Docker container that uses ffmpeg to auto-optimize a full directory of hero-video-files, ignoring non optimizable and failing files.

Recommended usage via Docker [Kitematic](https://kitematic.com/) & [Docker Hub](https://hub.docker.com/r/majamee/hero-videoptim/).

# Simplified usage (run in shell/ terminal/ cmd)
```sh
docker pull majamee/hero-videoptim
docker run -v /absolute/path/to/hero-videos-base-folder/:/video majamee/hero-videoptim
```
Please just replace in the command above the absolute path to your root video file folder and all videos inside (recursive) will be converted to web-optimized hero-videos (no-audio). You can also use [tags](https://hub.docker.com/r/majamee/hero-videoptim/tags/) like `majamee/hero-videoptim:edge` (e.g. uses [alpine](https://hub.docker.com/_/alpine/)'s edge version as base).

* `docker pull majamee/hero-videoptim` does update the instance image.
* `docker run...` will mount the folder `/absolute/path/to/hero-videos-base-folder` into the docker image and convert all video-files within that folder replacing the original with optimized versions and leaving everything that cannot be optimized without errors as is. Backups of the original image will be kept next to the hero-video-files (which have the audio-track removed) to allow autoplay.

# Examplary toolchain usage
Just use Kitematic to open the shared folder, place your video file in there, replace `"input.mkv"` in the commands below by your input video file (without `""`) and execute the shell commands subsequent into the Docker container.
```sh
# 1080p@CRF22 hero video
ffmpeg -y -threads 0 -i "input.mkv" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -crf 22 -movflags faststart -write_tmcd 0 "hero-optimized.mp4"
```

## Features
* Optimizes all video files in a folder or in any of its subfolders for web playback
* Prevents upscaling (maximum 1080p)
* Removes audio track to save bandwidth and to make autoplay for hero videos in all modern web browsers possible
* Optimized hero-video replaces the old file, which itself is being kept renamed as `*.backup`
* Checks result for negative compression and prohibits it (keeps original if so)
