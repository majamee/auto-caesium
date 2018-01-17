#!/bin/bash

# Text formatting details @https://misc.flogisoft.com/bash/tip_colors_and_formatting
# Reset
Color_Off='\e[0m'         # Text Reset

# Regular Colors
Black='\e[0;30m'          # Black
Red='\e[0;31m'            # Red
Green='\e[0;32m'          # Green
Yellow='\e[0;33m'         # Yellow
Blue='\e[0;34m'           # Blue
Purple='\e[0;35m'         # Purple
Cyan='\e[0;36m'           # Cyan
White='\e[0;37m'          # White

# Bold
Bold='\e[1m'               # Bold on
Bold_Off='\e[21m'          # Bold off

# Underline
Underline='\e[4m'          # Underline on
Underline_Off='\e[24m'     # Underline off

# Blinking
Blinking='\e[5m'          # Blinking on
Blinking_Off='\e[25m'     # Blinking off

# Reverse
Reverse='\e[7m'           # Reverse on
Reverse_Off='\e[27m'      # Reverse off

# Background
On_Black='\e[40m'         # Black
On_Red='\e[41m'           # Red
On_Green='\e[42m'         # Green
On_Yellow='\e[43m'        # Yellow
On_Light_Red='\e[101m'    # Light Red
On_Light_Blue='\e[104m'   # Light Blue

# Create tmp folder for transcoding
mkdir -p "/tmp/video/";
shopt -s nullglob;

echo -e "${Reverse}Please be aware, that the audio track of all videos in provided folder will be cut. Due to that, originals will be kept renamed.";
echo -e "${Reverse_Off}${Green}${Bold}\nStarting processing ${1}${Bold_Off}${Color_Off}\n";
cd /video/$1;
# Scan recursive for suitable files
for file in *
do
    if [ -d "${file}" ] ; then
        /bin/entrypoint.sh "${1}/${file}";
    else
        # Suitable video files are currently set to the following video file extensions
        if ( [ ${file: -4} == ".avi" ] || [ ${file: -4} == ".mkv" ] || [ ${file: -4} == ".mp4" ] || [ ${file: -4} == ".wmv" ] || [ ${file: -4} == ".ts" ] || [ ${file: -4} == ".mov" ] || [ ${file: -4} == ".flv" ] || [ ${file: -4} == ".webm" ] ); then
            if grep -Fxq "${file}" /video/.hero-videoptim
            then
                echo -e "${On_Light_Blue}${file} already optimized in previous run. Skipping${Color_Off}";
                continue
            fi
            # Cleanup
            rm -rf "/tmp/video/*";
            echo -e "${On_Yellow}${Bold}${file} ${Bold_Off}being optimized now! Please be patient.${Color_Off}";
            filename=$(basename "${file}");
            filename="${filename%.*}";
            frames=$(ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 "${file}");
            echo -e "\nCurrent video: ${file}\nDetected file name: ${filename}\nTotal # of frames: ${frames}\n";

            # Start transcoding @CRF22
            ffmpeg -v error -stats -y -threads 4 -i "${file}" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -preset veryslow -crf 22 -movflags faststart -write_tmcd 0 "/tmp/video/${file}";
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                oldsize=$(wc -c <"${file}");
                newsize=$(wc -c <"/tmp/video/${file}");
                if [ $newsize -lt $oldsize ]; then
                    chown `stat -c "%u:%g" "${file}"` "/tmp/video/${file}";
                    chmod `stat -c "%a" "${file}"` "/tmp/video/${file}";
                    mv "${file}" "${file}.backup";
                    mv "/tmp/video/${file}" "${file}";
                    echo "${file}" >> /video/.hero-videoptim;
                    echo -e "${On_Green}Optimized file ${Bold}${file} ${Bold_Off}successfully as hero-video${Color_Off}\n";
                else
                    echo -e "${On_Yellow}Optimized file for ${file} is not smaller. Trying alternative compression method (2pass@1500kbps).${Color_Off}";
                    # Cleanup
                    rm -rf "/tmp/video/*";
                    echo -e "${On_Yellow}${Bold}${file} ${Bold_Off}being optimized now with 2pass@1500kbps. Please be patient.${Color_Off}";
                    echo -e "\nCurrent video: ${file}\nDetected file name: ${filename}\nTotal # of frames: ${frames}\n";

                    # Start transcoding (2-pass@1500kbps)
                    ffmpeg -v error -stats -y -threads 4 -i "${file}" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -b:v 1500k -pass 1 -f mp4 /dev/null && \
                    ffmpeg -v error -stats -y -threads 4 -i "${file}" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -b:v 1500k -pass 2 -movflags faststart -write_tmcd 0 "/tmp/video/${file}"
                    # Clean-up 2pass logs
                    rm ffmpeg2pass-0.log*;

                    if [ ${PIPESTATUS[0]} -eq 0 ]; then
                        oldsize=$(wc -c <"${file}");
                        newsize=$(wc -c <"/tmp/video/${file}");
                        if [ $newsize -lt $oldsize ]; then
                            chown `stat -c "%u:%g" "${file}"` "/tmp/video/${file}";
                            chmod `stat -c "%a" "${file}"` "/tmp/video/${file}";
                            mv "${file}" "${file}.backup";
                            mv "/tmp/video/${file}" "${file}";
                            echo "${file}" >> /video/.hero-videoptim;
                            echo -e "${On_Green}Optimized file ${Bold}${file} ${Bold_Off}successfully as hero-video${Color_Off}\n";
                        else
                            echo "${file}" >> /video/.hero-videoptim;
                            echo -e "${On_Red}Optimized file for ${file} is not smaller. Skipping${Color_Off}";
                        fi
                    fi
                fi
            else
                echo -e "${On_Light_Red}Optimizing file ${file} failed. Skipping${Color_Off}";
            fi
        fi
    fi
done
