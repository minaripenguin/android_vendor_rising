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

# Calculate the date range for GIT_LOG
After_Date=$(date_format $changelog_days)
Until_Date=$(date_format 0)

# Loop through all the repositories
for repo_path in $REPO_LIST; do
    # Find all the commits within the days specifid
    GIT_LOG=$(git -C "$repo_path" log --pretty=format:'%cd%x09%s [%an]' --after="$After_Date" --until="$Until_Date" --date=short)

    # If there are any commits, add them to the changelog file
    if [ -n "$GIT_LOG" ]; then
        echo -e "\n====== $repo_path ======" >> $Changelog
        unset prev_commit_date
        # Process each changelog/commit separately
        echo "$GIT_LOG" | while read -r line; do
            # Extract commit date and message
            commit_date=${line%%$'\t'*}
            commit_msg=${line#*$'\t'}

            # If this commit is from a new date, print a header
            if [ "$commit_date" != "$prev_commit_date" ]; then
                echo -e "\n$commit_date" >> $Changelog
                prev_commit_date=$commit_date
            fi
            echo -e "   - $commit_msg" >> $Changelog
        done
    fi
done

# Fix the formatting of the changelog file
sed -i 's/project/   */g' $Changelog

# Copy the changelog file to the appropriate location
mv $Changelog $OUT_DIR/target/product/
