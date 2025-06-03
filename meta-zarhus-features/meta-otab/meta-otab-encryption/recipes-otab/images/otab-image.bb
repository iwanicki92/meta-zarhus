FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DESCRIPTION = "OTAB update image"

LICENSE = "CLOSED"

OTAB_FILES_WITH_VARIABLES = " \
    ${WORKDIR}/sw-description \
    ${WORKDIR}/otab-shell \
"

inherit otab-variables-preinstall swupdate

SRC_URI = " \
    file://sw-description \
    file://otab-shell \
"

DEPENDS += " cpio-native openssl openssl-native"

# images to build before building swupdate image
IMAGE_DEPENDS = "${OTAB_ROOTFS_IMAGE_NAME}"

# images and files that will be included in the .swu image
OTAB_SWUPDATE_IMAGES ?= "${OTAB_ROOTFS_IMAGE_NAME} ${OTAB_KERNEL_IMAGE_TYPE}-${MACHINE}"

SWUPDATE_IMAGES = "${OTAB_SWUPDATE_IMAGES}"

do_encrypt_images () {
    rm -f ${DEPLOY_DIR_IMAGE}/*.enc
    image_in="${DEPLOY_DIR_IMAGE}/${OTAB_ROOTFS_IMAGE_NAME}-${MACHINE}${OTAB_ROOTFS_IMAGE_FSTYPE}"
    # Remove multiple extension - image_out will have single extension .enc
    image_out="${image_in%%.*}".enc
    openssl enc -aes-256-cbc -in $image_in -out $image_out \
         -K ${SWUPDATE_ENC_KEY} -iv ${SWUPDATE_ENC_IV}
    image_in="${DEPLOY_DIR_IMAGE}/${OTAB_KERNEL_IMAGE_TYPE}-${MACHINE}.bin"
    # Remove multiple extension - image_out will have single extension .enc
    image_out="${image_in%%.*}".enc
    openssl enc -aes-256-cbc -in $image_in -out $image_out \
         -K ${SWUPDATE_ENC_KEY} -iv ${SWUPDATE_ENC_IV}
}

addtask do_encrypt_images after do_unpack do_prepare_recipe_sysroot before do_swuimage

# Equivalent of:
# SWUPDATE_IMAGES_FSTYPES[${OTAB_ROOTFS_IMAGE_NAME}] = "${OTAB_ROOTFS_IMAGE_TYPE}"
# written as Python anynomous function to allow for dynamic
# variable flag setting (OTAB_ROOTFS_IMAGE_NAME expansion as a flag name)
python () {
  image_name = d.getVar('OTAB_ROOTFS_IMAGE_NAME', True)
  d.setVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, ".enc")

  image_name = d.getVar('OTAB_KERNEL_IMAGE_TYPE', True) + '-' + d.getVar('MACHINE', True)
  d.setVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, ".enc")
}

do_swuimage[depends] += "${PN}:do_insert_otab_variables_preinstall"
