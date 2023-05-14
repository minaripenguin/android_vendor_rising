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

# Define the variables
Changelog=Changelog.txt
DEVICE=$1
changelog_days=${2:-10}

# Check if the changelog file exists, and if so, remove it
if [ -f $Changelog ]; then
    rm -f $Changelog
fi

# Create the changelog file
touch $Changelog

# Get a list of all the repositories
REPO_LIST="$(repo list --path | sed 's|^vendor/risingOTA$||')"

# Loop through the specified number of days
for i in $(seq 1 $changelog_days); do

    # Get the start and end dates
    After_Date=`date --date="$i days ago" +%m-%d-%Y`
    k=$(expr $i - 1)
    Until_Date=`date --date="$k days ago" +%m-%d-%Y`

    # Add a header to the changelog file
    echo "==================== $Until_Date =====================" >> $Changelog

    # Loop through all the repositories
    for repo_path in $REPO_LIST; do

        # Find commits between the two dates
        GIT_LOG="$(git -C "$repo_path" log --oneline --after="$After_Date" --until="$Until_Date")"

        # If there are any commits, add them to the changelog file
        if [ -n "$GIT_LOG" ]; then
            printf '\n   * '; echo "$repo_path"
            echo "$GIT_LOG" >> $Changelog
        fi
    done

    # Add a blank line to the changelog file
    echo >> $Changelog
done

# Fix the formatting of the changelog file
sed -i 's/project/   */g' $Changelog

# Copy the changelog file to the appropriate location
cp $Changelog $OUT_DIR/target/product/$DEVICE/system/etc/
mv $Changelog $OUT_DIR/target/product/$DEVICE/

