WEEKEND='false'

###### GET PARAMETERS #######

while getopts y:m:d:w: option
do
    case "${option}"
    in
        y) YEAR=${OPTARG};;
        m) MONTH=${OPTARG};;
        d) DAY=${OPTARG};;
        w) WEEKEND=$OPTARG;;
    esac
done

############################

DATE=$YEAR$MONTH$DAY

if  [[ -z "$DAY" ]] || [[ -z "$MONTH" ]] || [[ -z "$YEAR" ]] ; then
    echo "Usage: ./ilfoglio.sh -y YYYY -m MM -d DD"
    echo "Optional: -w true (if the chosen day is a Saturday)"
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
