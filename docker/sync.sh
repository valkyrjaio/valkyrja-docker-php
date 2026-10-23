#!/bin/bash
#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#

replaceSyncWith=site
syncDir="/var/www/sync/"

inotifywait -m -r -e modify,create,move "${syncDir}app" |
while read -r directory events filename; do
    if [[ $filename != *"tmp"* ]]
    then
        mkdir -p "${directory/sync/$replaceSyncWith}"
        cp "$directory$filename" "${directory/sync/$replaceSyncWith}$filename"
        echo -e "\e[95m$directory$filename changed\e[0m"
    fi
done
