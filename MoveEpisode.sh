PATTERN="(.*)[sS]{1}[0-9]+[eE]{1}[0-9]+"
FILEPATH=$1
TARGET_DIR=$2
FILEDIR=`dirname $FILEPATH`
FILENAME=`basename $FILEPATH`


if [ -z "$FILEPATH" ]; then
	echo "Missing arg0 file path" >> MoveEpisode.log
	exit 1
fi

if [ -z "$TARGET_DIR" ]; then
	echo "Missing arg1 target path (arg0=$FILEPATH)" >> MoveEpisode.log
	exit 1
fi

if ! [[ $FILENAME =~ $PATTERN ]]; then
	echo "Failed to extract show name from [$FILENAME]" >> MoveEpisode.log
	exit 1
fi

if [ -z "${BASH_REMATCH[0]}" ]; then
	echo "missing regex match" >> MoveEpisode.log
	exit 1
fi

SHOW_MATCH="${BASH_REMATCH[1]}"
#if [ -z "$SHOW_NAME" ]; then
SHOW_PARTS=$(echo $SHOW_MATCH | tr "." "\n")
SHOW_NAME=""
for Part in $SHOW_PARTS; do
	FIRST_CHAR=${Part:0:1}
	FIRST_CHAR=`echo $FIRST_CHAR | tr [a-z] [A-Z]`
	WORD=${Part:1}
	SHOW_NAME+="$FIRST_CHAR$WORD "
	#SHOW_NAME+="$Part "
done
SHOW_NAME=${SHOW_NAME::${#SHOW_NAME}-1}
echo "found show name [$SHOW_NAME] from $FILENAME" >> MoveEpisode.log

# work out new filename
TARGET_DIR+=$SHOW_NAME
mkdir -p "$TARGET_DIR"

if [ $? -ne 0 ]; then
	echo "Error with mkdir $TARGET_DIR" >> MoveEpisode.log
	exit 1
fi

TARGET_FILEPATH="$TARGET_DIR/$FILENAME"
mv "$FILEPATH" "$TARGET_FILEPATH"

if [ $? -ne 0 ]; then
	echo "Error with mv $FILEPATH $TARGET_FILEPATH" >> MoveEpisode.log
	exit 1
fi

echo "Moved $FILEPATH to $TARGET_FILEPATH" >> MoveEpisode.log

exit 0
