#!/bin/bash

# Modified to work with PHP CodeIgniter 4's config/Version.php

NOW="$(date +'%B %d, %Y')"
RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

LATEST_HASH=`git log --pretty=format:'%h' -n 1`

QUESTION_FLAG="${GREEN}?"
WARNING_FLAG="${YELLOW}! "
NOTICE_FLAG="${CYAN}❯"

ADJUSTMENTS_MSG="${QUESTION_FLAG} ${CYAN}Now you can make adjustments to ${WHITE}CHANGELOG.md${CYAN}. Then press enter to continue."
PUSHING_MSG="${NOTICE_FLAG} Pushing new version to the ${WHITE}origin${CYAN}..."

if [ -f "app/Config/Version.php" ]; then
    # Extract current version from Version.php
    CURRENT_VERSION=$(grep -oP 'public const VERSION = "\K[0-9\.]+" ' app/Config/Version.php)
    
    if [ -z "$CURRENT_VERSION" ]; then
        echo -e "${WARNING_FLAG} Could not find a version in config/Version.php."
        exit 1
    fi

    echo -e "${NOTICE_FLAG} Current version: ${WHITE}$CURRENT_VERSION"
    V_MAJOR=$(echo $CURRENT_VERSION | cut -d'.' -f1)
    V_MINOR=$(echo $CURRENT_VERSION | cut -d'.' -f2)
    V_PATCH=$(echo $CURRENT_VERSION | cut -d'.' -f3)

    # Suggest a new version (increment minor version)
    V_MINOR=$((V_MINOR + 1))
    V_PATCH=0
    SUGGESTED_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
    echo -ne "${QUESTION_FLAG} ${CYAN}Enter a version number [${WHITE}$SUGGESTED_VERSION${CYAN}]: "
    read INPUT_STRING
    if [ "$INPUT_STRING" = "" ]; then
        INPUT_STRING=$SUGGESTED_VERSION
    fi

    echo -e "${NOTICE_FLAG} Will set new version to be ${WHITE}$INPUT_STRING"

    # Update the version in config/Version.php
    sed -i "s/const VERSION = \"$CURRENT_VERSION\";/const VERSION = \"$INPUT_STRING\";/g" app/Config/Version.php

    echo "## $INPUT_STRING ($NOW)" > tmpfile
    git log --pretty=format:"  - %s" "v$CURRENT_VERSION"...HEAD >> tmpfile
    echo "" >> tmpfile
    echo "" >> tmpfile
    cat CHANGELOG.md >> tmpfile
    mv tmpfile CHANGELOG.md
    echo -e "$ADJUSTMENTS_MSG"
    read
    echo -e "$PUSHING_MSG"
    
    git add CHANGELOG.md app/Config/Version.php
    git commit -m "Bump version to ${INPUT_STRING}."
    git tag -a -m "Tag version ${INPUT_STRING}." "v$INPUT_STRING"
    git push origin --tags
else
    echo -e "${WARNING_FLAG} Could not find app/Config/Version.php."
    exit 1
fi

echo -e "${NOTICE_FLAG} Finished."
