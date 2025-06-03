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

# images to build before building swupdate image
IMAGE_DEPENDS = "${OTAB_ROOTFS_IMAGE_NAME}"

# images and files that will be included in the .swu image
OTAB_SWUPDATE_IMAGES ?= "${OTAB_ROOTFS_IMAGE_NAME} ${OTAB_KERNEL_IMAGE_TYPE}-${MACHINE}"

SWUPDATE_IMAGES = "${OTAB_SWUPDATE_IMAGES}"

# Equivalent of:
# SWUPDATE_IMAGES_FSTYPES[${OTAB_ROOTFS_IMAGE_NAME}] = "${OTAB_ROOTFS_IMAGE_TYPE}"
# written as Python anynomous function to allow for dynamic
# variable flag setting (OTAB_ROOTFS_IMAGE_NAME expansion as a flag name)
python () {
  image_name = d.getVar('OTAB_ROOTFS_IMAGE_NAME', True)
  image_fstype = d.getVar('OTAB_ROOTFS_IMAGE_FSTYPE', True)
  d.setVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, image_fstype)

  image_name = d.getVar('OTAB_KERNEL_IMAGE_TYPE', True) + '-' + d.getVar('MACHINE', True)
  image_fstype = d.getVar('OTAB_KERNEL_IMAGE_EXTENSION', True)
  d.setVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, image_fstype)
}

do_swuimage[depends] += "${PN}:do_insert_otab_variables_preinstall"
