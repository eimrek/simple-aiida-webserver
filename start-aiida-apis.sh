#!/bin/bash

# Specify the folder path
folder="./archives"

# starting port
port=5000

# Loop through all .aiida files in the folder
for file in "$folder"/*.aiida; do

    name="$(basename $file .aiida)"
    # set up profile and start rest api in background
    verdi profile setup core.sqlite_zip -p $name -n --filepath $file
    # NOTE, for production, use gunicorn!
    verdi -p $name restapi --hostname 0.0.0.0 --port $port &

    echo "Started restapi for profile $name!"

    port=$((port + 1))
done

# wait for the rest api processes, otherwise the container will exit
wait