#!/bin/bash

# Text formatting details @https://misc.flogisoft.com/bash/tip_colors_and_formatting
# Switch
SWITCH="\e["
# Reset
Color_Off='${SWITCH}0m'         # Text Reset

# Regular Colors
Black='${SWITCH}0;30m'          # Black
Red='${SWITCH}0;31m'            # Red
Green='${SWITCH}0;32m'          # Green
Yellow='${SWITCH}0;33m'         # Yellow
Blue='${SWITCH}0;34m'           # Blue
Purple='${SWITCH}0;35m'         # Purple
Cyan='${SWITCH}0;36m'           # Cyan
White='${SWITCH}0;37m'          # White

# Bold
Bold='${SWITCH}1'               # Bold on
Bold_Off='${SWITCH}21'          # Bold off

# Underline
Underline='${SWITCH}4'          # Underline on
Underline_Off='${SWITCH}24'     # Underline off

# Blinking
Blinking='${SWITCH}5m'          # Blinking on
Blinking_Off='${SWITCH}25m'     # Blinking off

# Reverse
Reverse='${SWITCH}7m'           # Reverse on
Reverse_Off='${SWITCH}27m'      # Reverse off

# Background
On_Black='${SWITCH}40m'         # Black
On_Red='${SWITCH}41m'           # Red
On_Green='${SWITCH}42m'         # Green
On_Yellow='${SWITCH}43m'        # Yellow
On_Light_Red='${SWITCH}101m'    # Light Red
On_Light_Blue='${SWITCH}104m'   # Light Blue

mkdir -p "/tmp/video/";
shopt -s nullglob;

echo -e "${Reverse}Please be aware, that the audio track of all videos in provided folder will be cut. Due to that, originals will be kept renamed.";
echo -e "${Reverse_Off}\n${Blinking}Processing ${1}\n";
cd /video/$1;
for file in *
do
    if [ -d "${file}" ] ; then
        /bin/entrypoint.sh "${1}/${file}";
    else
        if ( [ ${file: -4} == ".avi" ] || [ ${file: -4} == ".mkv" ] || [ ${file: -4} == ".mp4" ] || [ ${file: -4} == ".wmv" ] || [ ${file: -4} == ".ts" ] || [ ${file: -4} == ".mov" ] || [ ${file: -4} == ".flv" ] || [ ${file: -4} == ".webm" ] ); then
            if grep -Fxq "${file}" /video/.hero-videoptim
            then
                echo -e "${Blinking_Off}${On_Light_Blue}${file} already optimized in previous run. Skipping${Color_Off}";
                continue
            fi

            rm -rf "/tmp/video/*";
            ffmpeg -y -threads 4 -i "${file}" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -crf 22 -movflags faststart -write_tmcd 0 "/tmp/video/${file}";
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                oldsize=$(wc -c <"${file}");
                newsize=$(wc -c <"/tmp/video/${file}");
                if [ $newsize -lt $oldsize ]; then
                    chown `stat -c "%u:%g" "${file}"` "/tmp/video/${file}";
                    chmod `stat -c "%a" "${file}"` "/tmp/video/${file}";
                    mv "${file}" "${file}.backup";
                    mv "/tmp/video/${file}" "${file}";
                else
                    echo -e "${Blinking_Off}${On_Red}Optimized file for ${file} is not smaller. Skipping${Color_Off}";
                fi
            else
                echo -e "${Blinking_Off}${On_Light_Red}Optimizing file ${file} failed. Skipping${Color_Off}";
            fi

            echo "${file}" >> /video/.hero-videoptim;
            echo -e "${Blinking_Off}${On_Green}Optimized file ${Bold}${file} ${Bold_Off}successfully as hero-video${Color_Off}";
        fi
    fi
done
