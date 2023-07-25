#!/bin/bash
#
# Copyright (C) 2017-2022 crDroid Android Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Define the variables
DEVICE=$1
Changelog=Changelog.txt
changelog_days=${2:-10}
OUT_DIR=out

# Check if the changelog file exists, and if so, remove it
if [ -f $Changelog ]; then
    rm -f $Changelog
fi

# Create the changelog file
touch $Changelog

# Get a list of all the repositories
REPO_LIST="$(repo list --path | sed 's|^vendor/risingOTA$||')"

# date is broken on some distros (unknown option)
# Check operating system type for date command compatiblity
os=$(uname)
# function to handle date format
date_format() {
    if [ "$os" = "Linux" ]; then
        if [ "$1" -eq 1 ]; then
            echo $(date -d "$1 day ago" +'%Y-%m-%d' 2> /dev/null)
        else
            echo $(date -d "$1 days ago" +'%Y-%m-%d' 2> /dev/null)
        fi
    elif [ "$os" = "Darwin" ]; then
        echo $(date -v-"$1"d +'%Y-%m-%d' 2> /dev/null)
    else
        echo "Unsupported OS" >&2
        exit 1
    fi
}

# Loop through all the repositories
for repo_path in $REPO_LIST; do
    unset repo_header_written

    # Loop through the specified number of days
    for i in $(seq $changelog_days -1 1); do

        # Get the start and end dates
        Until_Date=$(date_format $(expr $i - 1))
        After_Date=$(date_format $i)

        # Create a temporary changelog file
        Changelog_temp=$Changelog.$Until_Date
        touch $Changelog_temp

        # Find commits between the two dates
        GIT_LOG="$(git -C "$repo_path" log --pretty=format:'   - %s [%an]' --after="$After_Date" --until="$Until_Date")"

        # If there are any commits, add them to the changelog file
        if [ -n "$GIT_LOG" ]; then
            # Only write the repo name once for each repo, not for each day
            if [ -z "$repo_header_written" ]; then
                echo "$repo_path" >> $Changelog_temp
                repo_header_written=1
            fi
            echo "$GIT_LOG" >> $Changelog_temp > /dev/null 2>&1
            # If there are commits, append the temp file content to the main changelog file
            cat $Changelog_temp >> $Changelog
            echo "" >> $Changelog # Adds an extra line for better separation between repos > /dev/null 2>&1
        fi
        # Remove temporary changelog file
        rm -f $Changelog_temp
    done
done

# Add a blank line to the changelog file
echo >> $Changelog

# Fix the formatting of the changelog file
sed -i 's/project/   */g' $Changelog

# Copy the changelog file to the appropriate location
cp $Changelog $OUT_DIR/target/product/$DEVICE/system/etc/
mv $Changelog $OUT_DIR/target/product/$DEVICE
