#!/bin/bash

# Text formatting details @https://misc.flogisoft.com/bash/tip_colors_and_formatting
# Switch
SWITCH="\e["
# Reset
Color_Off='${SWITCH}0m'       # Text Reset

# Regular Colors
Black='${SWITCH}0;30m'        # Black
Red='${SWITCH}0;31m'          # Red
Green='${SWITCH}0;32m'        # Green
Yellow='${SWITCH}0;33m'       # Yellow
Blue='${SWITCH}0;34m'         # Blue
Purple='${SWITCH}0;35m'       # Purple
Cyan='${SWITCH}0;36m'         # Cyan
White='${SWITCH}0;37m'        # White

# Bold
BBlack='${SWITCH}1;30m'       # Black
BRed='${SWITCH}1;31m'         # Red
BGreen='${SWITCH}1;32m'       # Green
BYellow='${SWITCH}1;33m'      # Yellow
BBlue='${SWITCH}1;34m'        # Blue
BPurple='${SWITCH}1;35m'      # Purple
BCyan='${SWITCH}1;36m'        # Cyan
BWhite='${SWITCH}1;37m'       # White

# Underline
UBlack='${SWITCH}4;30m'       # Black
URed='${SWITCH}4;31m'         # Red
UGreen='${SWITCH}4;32m'       # Green
UYellow='${SWITCH}4;33m'      # Yellow
UBlue='${SWITCH}4;34m'        # Blue
UPurple='${SWITCH}4;35m'      # Purple
UCyan='${SWITCH}4;36m'        # Cyan
UWhite='${SWITCH}4;37m'       # White

# Blinking
Blinking='${SWITCH}5m'          # Blinking on
Blinking_Off='${SWITCH}25m'     # Blinking off

# Reverse
Reverse='${SWITCH}7m'          # Reverse on
Reverse_Off='${SWITCH}27m'     # Reverse off

# Background
On_Black='${SWITCH}40m'       # Black
On_Red='${SWITCH}41m'         # Red
On_Green='${SWITCH}42m'       # Green
On_Yellow='${SWITCH}43m'      # Yellow
On_Light_Red='${SWITCH}101m'  # Light Red
On_Light_Blue='${SWITCH}104m' # Light Blue

mkdir -p "/tmp/video/";
shopt -s nullglob;

echo -e "${Reverse}Please be aware, that the audio track of all videos in provided folder will be cut. Due to that, originals will be kept renamed.${Reverse_Off}";
echo -e "\n${Blinking}Processing ${1}${Blinking_Off}\n";
cd /video/$1;
for file in *
do
    if [ -d "${file}" ] ; then
        /bin/entrypoint.sh "${1}/${file}";
    else
        if ( [ ${file: -4} == ".avi" ] || [ ${file: -4} == ".mkv" ] || [ ${file: -4} == ".mp4" ] || [ ${file: -4} == ".wmv" ] || [ ${file: -4} == ".ts" ] || [ ${file: -4} == ".mov" ] || [ ${file: -4} == ".flv" ] || [ ${file: -4} == ".webm" ] ); then
            if grep -Fxq "${file}" /video/.hero-videoptim
            then
                echo -e "${On_Light_Blue}${file} already optimized in previous run. Skipping${Color_Off}";
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
                    echo -e "${On_Red}Optimized file for ${file} is not smaller. Skipping${Color_Off}";
                fi
            else
                echo -e "${On_Light_Red}Optimizing file ${file} failed. Skipping${Color_Off}";
            fi

            echo "${file}" >> /video/.hero-videoptim;
            echo -e "${On_Green}Optimized file \e[1m${file} \e[21msuccessfully as hero-video${Color_Off}";
        fi
    fi
done
