OTAB_SWUPDATE_IMAGES = "${OTAB_ROOTFS_IMAGE_NAME}"
require recipes-otab/images/otab-image.inc
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

python () {
  image_name = d.getVar('OTAB_ROOTFS_IMAGE_NAME', True)
  image_fstype = d.getVar('OTAB_BOOT_A_IMAGE_FSTYPE', True)
  d.setVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, image_fstype)
  image_fstype = d.getVar('OTAB_BOOT_B_IMAGE_FSTYPE', True)
  d.appendVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, f" {image_fstype}")
  image_fstype = d.getVar('OTAB_ROOTFS_A_IMAGE_FSTYPE', True)
  d.appendVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, f" {image_fstype}")
  image_fstype = d.getVar('OTAB_ROOTFS_B_IMAGE_FSTYPE', True)
  d.appendVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name, f" {image_fstype}")

  image_name = d.getVar('OTAB_KERNEL_IMAGE_TYPE', True) + '-' + d.getVar('MACHINE', True)
  d.delVarFlag('SWUPDATE_IMAGES_FSTYPES', image_name)
}
