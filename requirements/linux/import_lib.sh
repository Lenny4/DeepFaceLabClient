set -e

result=$(ldd DeepFaceLabClient-linux/DeepFaceLabClient)
result=$(echo "$result" | grep --perl-regexp '.*=> /lib.* ' --only-matching)

readarray -t <<<"$result"

for (( i=0; i<${#MAPFILE[@]}; i++ ))
do
    MAPFILE[$i]=$(echo "${MAPFILE[$i]}" | xargs)
    filename=$(echo "${MAPFILE[$i]}" | grep --perl-regexp '.*=>' --only-matching)
    filename="${filename/ =>/""}"
    filepath=$(echo "${MAPFILE[$i]}" | grep --perl-regexp '=>.*' --only-matching)
    filepath="${filepath/=> /""}"
    cp "$filepath" DeepFaceLabClient-linux/lib/"$filename"
    echo "copied $filepath in DeepFaceLabClient-linux/lib/$filename"
done
