#!/bin/bash
# Run with no arguments to download today's paper
#

###### GET PARAMETERS #######
if [[ $# -eq 0 ]]; then
    echo "Assuming today's date: $(date +"%y-%m-%d")"
    DATE=$(date +"%y%m%d")
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
if [[ $weekday -eq 6  || $weekday -eq 7 ]]; then  # 6 and 7 are Saturday and Sunday
    WEEKEND='true'
fi
############################

if  [[ -z "$DAY" ]] || [[ -z "$MONTH" ]] || [[ -z "$YEAR" ]] ; then
    echo "Usage: ./ilfoglio.sh [-y YYYY -m MM -d DD]"
    echo "Scarica il giornale di oggi se non vengono dati argomenti."
else

    mkdir $DATE

    download () {
        if [ "$WEEKEND" = "true" ]; then
            curl -s -o ${DATE}/${1}.jpg https://edicola.ilfoglio.it/ilfoglio/books/weekend/$YEAR/${DATE}weekend/images/zoompages/Zoom-$1.jpg
        else
            curl -s -o ${DATE}/${1}.jpg https://edicola.ilfoglio.it/ilfoglio/books/ilfoglio/$YEAR/${DATE}ilfoglio/images/zoompages/Zoom-$1.jpg
        fi
    }

    echo "Downloading.."

    for i in {1..30}
    do
        download $i &
    done

    wait $(jobs -p)
    echo "Download completed. Files saved in ${DATE}/ ."

    echo "Cleaning up.."
    find ./${DATE} -exec file {} \; | grep HTML | cut -d: -f1 | xargs rm
    echo "Done."
fi
