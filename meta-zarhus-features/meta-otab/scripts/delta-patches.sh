#!/bin/bash
#
# SPDX-FileCopyrightText: 2020 3mdeb Embedded Systems Consulting <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

ROOT_DIR="$PWD"
TMP_DIR="$ROOT_DIR/meta-otab/scripts/tmp-dir"

VERSION_REGEXP="[0-9]*\.[0-9]*\.[0-9]*"
VERSION_LIST="ver-list"
OTAB_SHELL="otab-shell"
SW_DESC_FILE="sw-description"
PROD_IMG_SUFF="base-image"
DBG_IMG_SUFF="$PROD_IMG_SUFF-debug"
PART_IMG_SUFF="direct.p2.gz"

# Google Cloud Storage variables to get partition images

BUCKET_DEB=""
BUCKET_PROD=""

if [ ! -z "$TARGET" ]; then
    OPT=""
    if [ ! -z "$DEBUG" ]; then
      OPT="debug"
      KAS_FILE="$ROOT_DIR/meta-$TARGET/kas-debug.yml"
    else
      OPT="prod"
      KAS_FILE="$ROOT_DIR/meta-$TARGET/kas-prod.yml"
    fi

    DISTRO_FILE="$ROOT_DIR/meta-$TARGET/meta-$TARGET-distro/conf/distro/$TARGET-distro.conf"
    # FIXME: what if we have machine defined in one of include files
    MACHINE=$(grep -I machine "$KAS_FILE" | cut -d ' ' -f 2)
    DEPLOY_DIR="$ROOT_DIR/build/tmp/deploy/images/$MACHINE"

    PROD_IMG="$TARGET-$PROD_IMG_SUFF-$MACHINE"
    DBG_IMG="$TARGET-$DBG_IMG_SUFF-$MACHINE"
    KERNEL_TYPE="$(basename $(find $DEPLOY_DIR -name "*initramfs-$MACHINE.bin") | cut -d '-' -f 1)"
    KERNEL_FILE="$KERNEL_TYPE-initramfs-$MACHINE.bin"
    ARTIFACTS_DIR="$ROOT_DIR/artifacts/delta-patches/$OPT"
fi

function printHelp {
cat <<EOF
Usage: DEBUG= TARGET= $(basename "${0}") command
    Commands:
        help                        print this help
        create                      create delta patches based on the latest
                                    build version and versions available on the
                                    updates server
    Environment variables:
        DEBUG                       when specified, use debug rootfs image to
                                    create delta patches, by default the script
                                    will use prod image
        TARGET                      part of the rootfs image name, dependent on
                                    the project name, if TARGET is not
                                    specified, the script exits
    Examples:
        $0 help
        DEBUG=yes TARGET=xyz $0 create

EOF
exit 1

}

function errorExit {
    local _msg="$1"
    echo "$_msg"
    echo "Cleanup directories..."
    rm -rf "$TMP_DIR"
    exit 1
}

function errorCheck {
    local _ec="$?"
    local _msg="$1"

    if [ "$_ec" -ne 0  ]; then
        errorExit "$_msg (error code: $_ec)"
    fi
}

installDeps() {
    echo "Checking the required dependencies..."
    if rdiff --version > /dev/null 2>&1 && gzip --version > /dev/null 2>&1; then
        echo "Dependencies already installed."
    else
        echo "Installing the required dependencies..."
        if command -v apt > /dev/null; then
            sudo apt update
            sudo apt install rdiff gzip
        elif command -v dnf > /dev/null; then
            sudo dnf check-update
            sudo dnf install librsync gzip
        else
            errorExit "Couldn't find package manager. Dependencies not installed."
        fi
    fi
}

downloadFromGCS() {
    local _img="$1"
    local _bucket=""
    if [ ! -z "$DEBUG" ]; then
        _bucket="$BUCKET_DEB"
    else
        _bucket="$BUCKET_PROD"
    fi
    local _rootfsBucket="https://storage.googleapis.com/$_bucket/rootfs-image"
    local _verList="versions.txt"

    pushd "$TMP_DIR" || exit
    # Download list of available rootfs images
    wget "$_rootfsBucket/$_verList"
    errorCheck "Cannot download list of rootfs images from the server"
    while read -r _ver
    do
        wget "$_rootfsBucket/$_img-v$_ver.$PART_IMG_SUFF"
        errorCheck "Cannot download rootfs image for version $_ver"
    done < "$_verList"
    popd || exit
}

prepareNeededRootfs() {
    local _img="$1"
    # Download all rootfs images from the update server use one of given
    # options
    downloadFromGCS "$_img"

    # Copy newest rootfs from Yocto deploydir
    cp "$DEPLOY_DIR/$_img.$PART_IMG_SUFF" "$TMP_DIR"
    errorCheck "Copying latest rootfs image failed."

    # Copy newest kernel image from Yocto deploydir
    cp "$DEPLOY_DIR/$KERNEL_FILE" "$TMP_DIR"
    errorCheck "Copying latest initramfs bzImage failed."

    pushd "$TMP_DIR" || exit
    gzip -d *."$PART_IMG_SUFF"
    errorCheck "Decompressing rootfs images failed."
    # create list of base versions, sort names in alphabetical order and
    # get only version part of the name
    ls -1 | grep -o "$VERSION_REGEXP" > $VERSION_LIST
    popd || exit
}

createDeltas() {
    local _sigFile="sig-file"
    local _deltaImg="image.rdiff.delta"
    local _partImgSuff="direct.p2"
    local _updFiles="$SW_DESC_FILE $OTAB_SHELL $_deltaImg.gz $KERNEL_FILE"
    local _ver=""
    local _swu_entry=""
    local _new_ver=$(grep DISTRO_VERSION "$DISTRO_FILE" | grep -o "$VERSION_REGEXP")
    echo "Preparing delta patches..."
    mkdir -p "$TMP_DIR" "$ARTIFACTS_DIR"
    _img=""
    if [ ! -z "$DEBUG" ]; then
        _img="$DBG_IMG"
    else
        _img="$PROD_IMG"
    fi
    prepareNeededRootfs "$_img"

    cp "$ROOT_DIR/meta-otab/scripts/delta-$SW_DESC_FILE" "$TMP_DIR/$SW_DESC_FILE"
    cp "$ROOT_DIR/meta-otab/scripts/delta-$OTAB_SHELL" "$TMP_DIR/$OTAB_SHELL"
    pushd "$TMP_DIR" || exit
    while read -r _ver
    do
        # provide correct names to sw-description
        sed -i -e "s/<PROJECT_KERNEL_FILE>/${KERNEL_FILE}/g" "$SW_DESC_FILE"
        sed -i -e "s/<PROJECT_KERNEL_TYPE>/${KERNEL_TYPE}/g" "$SW_DESC_FILE"
        # create diff image
        rdiff signature "$_img-v$_ver.$_partImgSuff" "$_sigFile"
        errorCheck "Creating signature file for version $_ver failed."
        rdiff delta "$_sigFile" "$_img.$_partImgSuff" "$_deltaImg"
        errorCheck "Creating delta image failed with $_ver as base version."
        gzip "$_deltaImg"
        for _swu_entry in $_updFiles
        do
            echo "$_swu_entry"
        done | cpio -ov -H crc > "$TARGET-delta-patch-v$_ver-v$_new_ver.swu"
        cp "$TARGET-delta-patch-v$_ver-v$_new_ver.swu" "$ARTIFACTS_DIR"
        errorCheck "Copying created delta patch for base version $_ver failed."
        rm "$_sigFile" "$_deltaImg.gz"
        errorCheck "Removing $_sigFile and $_deltaImg.gz failed"
    done < "$VERSION_LIST"
    popd || exit
    rm -rf "$TMP_DIR"
}

CMD="$1"

case "$CMD" in
    "create")
        if [ ! -z "$TARGET" ]; then
            echo "Create delta patches for $TARGET project!"
        else
            echo "No TARGET specified, exiting!" && printHelp
            exit 1
        fi
        installDeps
        createDeltas
        ;;
    "help")
        printHelp
        ;;
    *)
        echo "Invalid COMMAND: \"$CMD\""
        printHelp
esac

