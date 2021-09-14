#!/bin/bash
set -e
SRC="$1"
echo SRC: "$1"
THUMB_DIR=".thumb"
MAX_WIDTH=540
# cd "$SRC"
REGEX_IMAGE_PATTERN="bmp|dib|cgm|drle|emf|fits|fit|fts|gif|ief|jls|jp2|jpg2|jpg|jpeg|jpe|jfif|jpm|jpgm|jpx|jpf|ktx|png|btif|btf|pti|svg|svgz|t38|tiff|tif|tfx|psd|azv|uvi|uvvi|uvg|uvvg|djvu|djv|dwg|dxf|fbs|fpx|fst|mmr|rlc|pgb|ico|apng|mdi|hdr|rgbe|xyze|spng|spn|s1n|sgif|sgi|s1g|sjpg|sjp|s1j|tap|vtf|wbmp|xif|pcx|wmf|webp|ras|pnm|pbm|pgm|ppm|rgb|tga|xbm|xpm|xw"
REGEX_VIDEO_PATTERN="3gp|3gpp|3g2|3gpp2|m4s|mj2|mjp2|mp4|mpg4|m4v|mpeg|mpg|mpe|m1v|m2v|ogv|mov|qt|uvh|uvvh|uvm|uvvm|uvu|uvvu|uvp|uvvp|uvs|uvvs|uvv|uvvv|dvb|fvt|mxu|m4u|pyv|nim|bik|bk2|smk|smpg|s11|s14|sswf|ssw|smov|smo|s1q|viv|webm|axv|flv|fxm|mkv|mk3d|asx|wm|wmv|wmx|wvx|avi|movie"
find "$SRC" -type f -print0  | while read -d $'\0' file; do
    if echo "$file" | grep -Eq "/($THUMB_DIR|@eaDir)/.+$"; then
        continue
    fi
    isVideo=0
    (echo "$file" | grep -Eiq "^.+/.*\.($REGEX_IMAGE_PATTERN)$") && isImage=1 ||isImage=0
    if [ "$isImage" == "0" ]; then
        (echo "$file" | grep -Eiq "^.+/.*\.($REGEX_VIDEO_PATTERN)$") && isVideo=1 ||isVideo=0
    fi
    if [ "$isImage" == "1" ] || [ "$isVideo" == "1" ];  then
        echo "$file"
        thumbFileName="$(basename "$file").webp"
        thumbDir="$(dirname "$file")/$THUMB_DIR"
        thumbFile="$thumbDir/$thumbFileName"
        if [ ! -d "$thumbDir" ]; then 
            echo "making dir $thumbDir"
            mkdir -p "$thumbDir"; 
        fi
        if [ -f "$thumbFile" ]; then
            if (( $(stat -c '%Y' "$file") > $(stat -c '%Y' "$thumbFile") )); then
                echo "$file --> $thumbFile thumb modify time match origin, SKIP"
                continue
            fi
        fi
        echo "$file --> $thumbFile"
        if [ "$isImage" == "1" ]; then
            convert -flatten -quality 75 -thumbnail "${MAX_WIDTH}x" "$file" "$thumbFile" || touch "$thumbFile"
        else
            ffmpeg -i "$file" -nostdin -nostats -hide_banner -loglevel panic -vcodec mjpeg -vframes 1 -an -f rawvideo -filter:v scale="$MAX_WIDTH:-1" -ss `ffmpeg -i "$file" -nostdin 2>&1 | grep Duration | awk '{print $2}' | tr -d , | awk -F ':' '{print ($3+$2*60+$1*3600)/2}'` "$thumbFile" 1>/dev/null || touch "$thumbFile"
        fi
        fileSize=$(stat -c %s "$file")
        thumbFileSize=$(stat -c %s "$thumbFile")
        if (( $fileSize < $thumbFileSize )); then
            echo "thumb large then origin, erase thumb!"
            > "$thumbFile"
        fi
        MODIFY_DATE=$(date -d @$(( $(stat -c '%Y' "$file") - 1)) '+%Y%m%d%H%M.%S')
        touch -amt "$MODIFY_DATE" "$thumbFile"
    fi
done
