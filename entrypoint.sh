#!/bin/bash
shopt -s nullglob

echo "Processing ${1}";
cd /hero-video/$1;
for file in *
do
    if [ -d "${file}" ] ; then
        /bin/entrypoint.sh "${1}/${file}";
    else 
        if ( [ ${file: -4} == ".png" ] || [ ${file: -4} == ".jpg" ] ); then
            if grep -Fxq "${file}" /hero-video/.herovidoptimized
            then
                echo "${file} already optimized in previous run. Skipping";
                continue
            fi
            
            rm -rf "/tmp/hero-video/*";
            caesiumclt -q 80 -o "/tmp/caesium/" "${file}" | cat; # suppress segmentation faults from caesium for the time beeing
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                oldsize=$(wc -c <"${file}")
                newsize=$(wc -c <"/tmp/hero-video/${file}")
                if [ $newsize -lt $oldsize ]; then
                    chown `stat -c "%u:%g" "${file}"` "/tmp/hero-video/${file}";
                    chmod `stat -c "%a" "${file}"` "/tmp/hero-video/${file}";
                    mv "/tmp/hero-video/${file}" "${file}";
                else
                    echo "Optimized file is not smaller. Skipping";
                fi
            else
                echo "Optimizing file ${file} failed. Skipping";
            fi
            
            echo "${file}" >> /hero-video/.herovidoptimized
        fi
    fi
done
