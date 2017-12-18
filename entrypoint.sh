#!/bin/bash
shopt -s nullglob

echo "Please be aware, that the audio track of all videos in provided folder will be cut. Due to that, originals will be kept renamed.";
echo "Processing ${1}";
cd /hero-video/$1;
for file in *
do
    if [ -d "${file}" ] ; then
        /bin/entrypoint.sh "${1}/${file}";
    else 
        if ( [ ${file: -4} == ".avi" ] || [ ${file: -4} == ".mkv" ] || [ ${file: -4} == ".mp4" ] || [ ${file: -4} == ".wmv" ] || [ ${file: -4} == ".ts" ] || [ ${file: -4} == ".mov" ] || [ ${file: -4} == ".flv" ] || [ ${file: -4} == ".webm" ] ); then
            if grep -Fxq "${file}" /hero-video/.herovidoptimized
            then
                echo "${file} already optimized in previous run. Skipping";
                continue
            fi
            
            rm -rf "/tmp/hero-video/*";
            ffmpeg -y -threads 4 -i "${file}" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -crf 22 -movflags faststart -write_tmcd 0 "/tmp/hero-video/${file}"; # optimize hero-video
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                oldsize=$(wc -c <"${file}")
                newsize=$(wc -c <"/tmp/hero-video/${file}")
                if [ $newsize -lt $oldsize ]; then
                    chown `stat -c "%u:%g" "${file}"` "/tmp/hero-video/${file}";
                    chmod `stat -c "%a" "${file}"` "/tmp/hero-video/${file}";
                    mv "${file}" "${file}.backup";
                    mv "/tmp/hero-video/${file}" "${file}";
                else
                    echo "Optimized file is not smaller. Skipping";
                fi
            else
                echo "Optimizing file ${file} failed. Skipping";
            fi
            
            echo "${file}" >> /hero-video/.herovidoptimized;
        fi
    fi
done
