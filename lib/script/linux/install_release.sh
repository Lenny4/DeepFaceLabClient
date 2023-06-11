set -e

#just to be sure that DeepFaceLabClient is closed
sleep 2

folderName=$1
folderPath=$2
downloadFileName=$3
execPath=$4
createdFolder=$5

rm -rf $folderPath/$folderName
unzip -o $folderPath/$downloadFileName -d $folderPath
#to preserve shortcut and symbolic link
mv $folderPath/$createdFolder $folderPath/$folderName
$execPath