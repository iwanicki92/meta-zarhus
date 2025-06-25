FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://create_overlay_fs"
PACKAGES += "initramfs-module-create-overlay-fs"

# nooelint: oelint.var.order.SUMMARY
SUMMARY:initramfs-module-create-overlay-fs = "Recreate ext4 fs on rwoverlay partition after encryption"
# nooelint: oelint.var.filesoverride
FILES:initramfs-module-create-overlay-fs = "/init.d/08-create_overlay_fs"
RDEPENDS:initramfs-module-create-overlay-fs = " \
    ${PN}-base \
    util-linux-lsblk \
    e2fsprogs-mke2fs \
    util-linux-fdisk \
"

OTAB_FILES_WITH_VARIABLES:append = " ${D}/init.d/08-create_overlay_fs"

do_install:append () {
    install -m 0755 "${WORKDIR}/create_overlay_fs" "${D}/init.d/08-create_overlay_fs"
}
