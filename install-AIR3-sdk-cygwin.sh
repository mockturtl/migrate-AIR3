#!/bin/sh

# This script downloads the Adobe AIR 3.0 SDK, and merges it with an existing Flex SDK.
# After running, add the new sdk in Flash Builder.
# To reconfigure an existing project, point to the new sdk in Library Paths, and update its AIR application descriptor: 
#
# /path/to/project/src/foo-app.xml
#     <application xmlns="http://ns.adobe.com/air/application/3.0">
#
# One other thing... I've only tested this in pieces, so it's probably a good idea to back up your original sdk source directory first.

SDK_VERSION=4.5.1
NEW_SDK_NAME=${SDK_VERSION}+AIR3
FLASH_PLAYER_PATH=http://fpdownload.macromedia.com/pub/flashplayer/updaters/11/
FLASH_PLAYER_VERSION=11.0

# Windows 64-bit (cygwin)
FLEX_PATH=/cygdrive/c/Program\ Files\ \(x86\)/Adobe/Adobe\ Flash\ Builder\ 4.5/sdks/
AIR3_PATH=http://airdownload.adobe.com/air/win/download/latest/
AIR3_ZIPFILE=AdobeAIRSDK.zip
FLASH_PLAYER_FILE=flashplayer_11_sa_debug_32bit.exe

# OSX
# note: Adobe packages downloads differently for Mac versus Windows.  The commands below will need modification to unpack them correctly.  
#FLEX_PATH=/path/to/FlashBuilder/sdks/
#AIR3_PATH=http://airdownload.adobe.com/air/mac/download/latest/
#AIR3_ZIPFILE=AdobeAIRSDK.tbz2
#FLASH_PLAYER_FILE=flashplayer_11_sa_debug.app.zip

TARGET_DIR=${FLEX_PATH}${NEW_SDK_NAME} 


if [ ! -d "${FLEX_PATH}${SDK_VERSION}/" ]; then
    echo "Could not find directory: " ${FLEX_PATH}${SDK_VERSION}
    echo "Check local variables -- aborting"
    exit
else
    echo "Found directory!"
    # make a copy of the existing sdk 
    mkdir "${TARGET_DIR}" 
    cd "${FLEX_PATH}${SDK_VERSION}" 
    cp -nr . "${TARGET_DIR}"
    cd "${TARGET_DIR}" 
    
    # create a unique identifier for Flash Builder 
    sed -i 's/<name>.*<\/name>/<name>Flex '${SDK_VERSION}'+AIR3<\/name>/' flex-sdk-description.xml
 
    # download the new sdk
    wget -nc ${AIR3_PATH}${AIR3_ZIPFILE} 
   
    # unzip the sdk into the new location
    unzip ${AIR3_ZIPFILE} .
    
    # cleanup 
    rm ${AIR3_ZIPFILE}
    
    # update config files for flash player 11, swf file format v13
    cd frameworks
    sed -i 's/<target-player>.*<\/target-player>/<target-player>11.0.0<\/target-player>/' air-config.xml airmobile-config.xml flex-config.xml
    sed -i 's/<swf-version>.*<\/swf-version>/<swf-version>13<\/swf-version>/' air-config.xml airmobile-config.xml flex-config.xml
    
    # download flash player standalone as "playerglobal.swc"
    cd libs/player 
    mkdir ${FLASH_PLAYER_VERSION}
    cd ${FLASH_PLAYER_VERSION}
    wget -nc ${FLASH_PLAYER_PATH}${FLASH_PLAYER_FILE}
    mv ${FLASH_PLAYER_FILE} playerglobal.swc 
fi