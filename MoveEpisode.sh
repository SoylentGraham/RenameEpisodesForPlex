PATTERN="(.*)[sS]{1}[0-9]+[eE]{1}[0-9]+"
TARGET_DIR="$2/"


if [ -z $1 ]; then
	echo "Missing arg0 filename or path" >> MoveEpisode.log
	exit 1
fi

if [ -z "$TARGET_DIR" ]; then
	echo "Missing arg1 target path (arg0=$FILEPATH)" >> MoveEpisode.log
	exit 1
fi


#	returns 0/1 as false/true
function ProcessFilename()
{
	FILEPATH=$1
	echo "running: $FILEPATH" >> MoveEpisode.log
	FILEDIR=`dirname $FILEPATH`
	FILENAME=`basename $FILEPATH`

	if ! [[ $FILENAME =~ $PATTERN ]]; then
		echo "Failed to extract show name from [$FILENAME]" >> MoveEpisode.log
		return 0
	fi

	if [ -z "${BASH_REMATCH[0]}" ]; then
		echo "missing regex match" >> MoveEpisode.log
		return 0
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
	SHOW_TARGET_DIR="$TARGET_DIR$SHOW_NAME"
	mkdir -p "$SHOW_TARGET_DIR"

	if [ $? -ne 0 ]; then
		echo "Error with mkdir $SHOW_TARGET_DIR" >> MoveEpisode.log
		return 0
	fi

	TARGET_FILEPATH="$SHOW_TARGET_DIR/$FILENAME"
	mv "$FILEPATH" "$TARGET_FILEPATH"

	if [ $? -ne 0 ]; then
		echo "Error with mv $FILEPATH $TARGET_FILEPATH" >> MoveEpisode.log
		return 0
	fi

	echo "Moved $FILEPATH to $TARGET_FILEPATH" >> MoveEpisode.log

	return 1
}


# run on directory if specified, otherwise single file
if [ -d "$1" ]; then
	echo "Running on directory [$1]" >> MoveEpisode.log

	# IFS sets output to line endings otherwise we can't handle filenames with spaces
	# https://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
	IFS=$(echo -en "\n\b")
	for FilePath in "$1/*.*"; do
		ProcessFilename $FilePath
	done
else
	echo "Running on single filename [$1]" >> MoveEpisode.log
	ProcessFilename $1
fi

exit 0
