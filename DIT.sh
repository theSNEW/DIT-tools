#!/bin/bash

VOLUMES=$(ls /volumes)
DATA=''

WORKING_DRIVE=$(cat "$(dirname "$0")/WORKING_DRIVE" 2>/dev/null)
MASTER_DRIVE=$(cat "$(dirname "$0")/MASTER_DRIVE" 2>/dev/null)
CLONE_DRIVE=$(cat "$(dirname "$0")/CLONE_DRIVE" 2>/dev/null)
CLOUD_DIR='macOS_1015_Catalina/Users/harry/Google Drive/02_JOBS/2021/ESTUARY/DIT-DOCUMENTATION' # NEEDS A WAY FOR THE USER TO POPULATE THE CLOUD DRIVE PATHWAY THROUGH A SELECTION MENU OR SIMILAR...

PROJECT_NAME=$(cat "$(dirname "$0")/PROJECT_NAME" 2>/dev/null)
SHOOT_DATE_UNIT_DAY=$(cat "$(dirname "$0")/SHOOT_DATE_UNIT_DAY" 2>/dev/null)

#####################################################################
#####################################################################

# A function that allows the user to assign a volume (from a choice of those currently mounted) to a variable.
selectDestination() {
    echo "Select your ${1}"
    echo
    select VOLUME_VARIABLE in $VOLUMES
    do
        echo
        echo "${1}: $VOLUME_VARIABLE"
        echo
        break
    done

    DATA=${VOLUME_VARIABLE}
}

# A function that creates the DIT folder structure within a directory named with today's date. This directory is created within the volume and parent directory passed in the first and second arguments.
folderStructure() {
  mkdir -p /volumes/${1}/${2}/${3}/{01_CAMERA,02_SOUND,03_DOCUMENTATION/{BYTE-CHECKS,CALLSHEET,CDLs,METADATA,REPORTS},04_FRAME-GRABS}
}

#####################################################################
#####################################################################

while getopts abcdefg OPTION
do
  case ${OPTION} in
    a)
      # Allows the user to enter the project name into the PROJECT_NAME variable file
      echo
      read -p "Enter the Project Name: " 
      echo ${REPLY} > "$(dirname "$0")/PROJECT_NAME"
      PROJECT_NAME=$(cat "$(dirname "$0")/PROJECT_NAME") 
      echo
      echo "The Project Name is ${PROJECT_NAME}"
      echo
      ;;
    b)
      echo 'THIS OPTION IS STILL UNDER CONSTRUCTION, DO NOT USE.'
      # # Allows the user to select 2 candidate drives (from those that are currently mounted) to be used for MASTER & CLONE and formats/renames them to a set template.
      # THIS OPTION IS STILL BEING BUILT, DO NOT USE.
      # diskutil list external physical
      # diskutil eraseDisk JHFS+ "${PROJECT_NAME}"__MASTER-01 GPT disk60
      # diskutil eraseDisk JHFS+ "${PROJECT_NAME}"__CLONE-01 GPT disk60
      ;;
    c)
      # Allows the user to select Working, Master, and Clone drives
      echo
      selectDestination 'Working Drive'
      echo ${DATA} > "$(dirname "$0")/WORKING_DRIVE"
      selectDestination 'Master Drive'
      echo ${DATA} > "$(dirname "$0")/MASTER_DRIVE"
      # selectDestination 'Clone Drive'
      # echo ${DATA} > "$(dirname "$0")/CLONE_DRIVE"
      WORKING_DRIVE=$(cat "$(dirname "$0")/WORKING_DRIVE" 2>/dev/null)
      MASTER_DRIVE=$(cat "$(dirname "$0")/MASTER_DRIVE" 2>/dev/null)
      # CLONE_DRIVE=$(cat "$(dirname "$0")/CLONE_DRIVE" 2>/dev/null)
      echo "Working Drive is: ${WORKING_DRIVE}"
      echo "Master Drive is: ${MASTER_DRIVE}"
      # echo "Clone Drive is: ${CLONE_DRIVE}"
      echo
      ;;
    d)
     # Uses the folder structure function above to create the DIT folder structure on the Working, Master, and Clone drives. 
      echo
      read -p "Enter the UNIT NAME (MAIN, 2ND, ETC..): " UNIT_NAME
      read -p "Enter a 2 digit SHOOT DAY NUMBER (00, 01, 02, ETC..): " SHOOT_DAY_NUMBER
      echo $(date +%y%m%d)__"$UNIT_NAME"-"$SHOOT_DAY_NUMBER" > "$(dirname "$0")/SHOOT_DATE_UNIT_DAY"
      SHOOT_DATE_UNIT_DAY=$(cat "$(dirname "$0")/SHOOT_DATE_UNIT_DAY" 2>/dev/null)
      folderStructure "${WORKING_DRIVE}" "${PROJECT_NAME}" "${SHOOT_DATE_UNIT_DAY}"
      folderStructure "${MASTER_DRIVE}" "${PROJECT_NAME}" "${SHOOT_DATE_UNIT_DAY}"
      # folderStructure "${CLONE_DRIVE}" "${PROJECT_NAME}" "${SHOOT_DATE_UNIT_DAY}"
      echo
      ;;
    e)
      # Clones WORKING DRIVE contents (excluding MASTER CAMERA & SOUND files) onto the Master & Clone drives.
      cd /
      rsync --write-batch="/volumes/${WORKING_DRIVE}/${PROJECT_NAME}/batch" -avhW --progress --delete --exclude {'01_CAMERA','02_SOUND'} "/volumes/${WORKING_DRIVE}/${PROJECT_NAME}/${SHOOT_DATE_UNIT_DAY}/" "/volumes/${MASTER_DRIVE}/${PROJECT_NAME}/${SHOOT_DATE_UNIT_DAY}/"
      # rsync --read-batch="/volumes/${WORKING_DRIVE}/${PROJECT_NAME}/batch" -avrhW "/volumes/${CLONE_DRIVE}/${PROJECT_NAME}/${SHOOT_DATE_UNIT_DAY}/"
      ;;
    f)
      # Clones WORKING DRIVE contents (excluding MASTER CAMERA & SOUND, and TRANSCODE files) onto Cloud Drive.
      cd /
      rsync -avhW --progress --delete --exclude {'01_CAMERA','02_SOUND','05_TRANSCODES'} "/volumes/${WORKING_DRIVE}/${PROJECT_NAME}/${SHOOT_DATE_UNIT_DAY}" "/volumes/${CLOUD_DIR}/"
      ;;
    g)
      # Clones Framegrab JPGs onto DPs Dropbox.
      cd /
      rsync -avhW --progress --delete --exclude '*.drx' "/volumes/${WORKING_DRIVE}/${PROJECT_NAME}/${SHOOT_DATE_UNIT_DAY}/04_FRAME-GRABS/" "/volumes/macOS_1015_Catalina/Users/harry/Dropbox/Harry‘s references/${SHOOT_DATE_UNIT_DAY}/"
      ;;
      esac
done