#!/bin/bash
# Run with no arguments to download today's paper
#

###### GET PARAMETERS #######
if [[ $# -eq 0 ]]; then
    echo "Scarico il giornale di oggi: $(date +"%d-%m-%Y")"
    DATE=$(date +"%Y%m%d")
    YEAR=$(date +"%Y")
else
    while getopts y:m:d:w: option; do
        case "${option}" in
            y) YEAR=${OPTARG};;
            m) MONTH=${OPTARG};;
            d) DAY=${OPTARG};;
        esac
    done
    DATE=$YEAR$MONTH$DAY
fi

weekday=$(date -d $DATE +"%u")
if [[ $weekday -eq 6 || $weekday -eq 7 ]]; then  # 6 and 7 are Saturday and Sunday
    WEEKEND='true'
fi
############################

if  [[ -z $DATE ]] ; then
    echo "Usage: ./ilfoglio.sh [-y YYYY -m MM -d DD]"
    echo "Scarica il giornale di oggi se non vengono dati argomenti."
else
    download_dir="ilfoglio_$DATE"
    mkdir -p "$download_dir"
    cd $download_dir
    echo "Downloading.."
    if [ "$WEEKEND" = "true" ]; then
        function download_page(){
            curl -s -o "$(printf "%02d" $1).jpg" "https://edicola.ilfoglio.it/ilfoglio/books/weekend/$YEAR/${DATE}weekend/images/zoompages/Zoom-$1.jpg"
        }
    else
        function download_page(){
            curl -s -o "$(printf "%02d" $1).jpg" "https://edicola.ilfoglio.it/ilfoglio/books/ilfoglio/$YEAR/${DATE}ilfoglio/images/zoompages/Zoom-$1.jpg"
        }
    fi
    for i in `seq 1 30`; do
        download_page $i &
    done
    wait $(jobs -p)

    echo "Download completed. Files saved in $download_dir."
    cd ..

    #echo "Cleaning up.."
    find ./$download_dir -exec file {} \; | grep HTML | cut -d: -f1 | xargs rm 2>/dev/null
    echo "Done."
fi
