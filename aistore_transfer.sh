#!/bin/bash

# (base) smt@a800svr:~$ ssh -L 5626:localhost:8080 -L 8081:localhost:8081 -p 8022 smt@220.241.203.34
BUCKET_NAME=AID08218

REMOTE_AIS="http://localhost:5626"
LOCAL_AIS="http://localhost:8080"
BUCKET_FILE="bucket_names.txt"

while read bucket; do
    echo "$bucket"
    bucket_name=${bucket##*/}
    temp_dir=$(mktemp -d "/tmp/${bucket_name}_XXXXXX")
    echo "Downloading bucket $bucket_name to $temp_dir"
    pushd "$temp_dir" > /dev/null

    export AIS_ENDPOINT=$REMOTE_AIS
    echo "Downloading bucket $bucket_name from $REMOTE_AIS"
    yes | ais object get "$bucket" --prefix="$bucket_name"

    if [ "$(ls -A "$temp_dir")" ]; then
        export AIS_ENDPOINT=$LOCAL_AIS
        echo "Uploading bucket $bucket_name to $LOCAL_AIS"
        yes | ais object put "$temp_dir" "$bucket"
    else
        echo "No files downloaded for $bucket_name, skipping upload."
    fi

    popd > /dev/null
    echo "Cleaning up temporary directory $temp_dir"
    rm -rf "$temp_dir"
done < $BUCKET_FILE

