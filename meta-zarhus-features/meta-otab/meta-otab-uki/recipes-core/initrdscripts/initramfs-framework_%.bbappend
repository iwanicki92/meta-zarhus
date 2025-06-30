FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://create_overlay"
PACKAGES += "initramfs-module-create-overlay"

# nooelint: oelint.var.order.SUMMARY
SUMMARY:initramfs-module-create-overlay = "initramfs support for creating partition for overlay during first boot"
# nooelint: oelint.var.filesoverride
FILES:initramfs-module-create-overlay = "/init.d/06-create_overlay"
RDEPENDS:initramfs-module-create-overlay = " \
    ${PN}-base \
    util-linux-lsblk \
    e2fsprogs-mke2fs \
    util-linux-fdisk \
"

inherit otab_variables_postinstall
OTAB_FILES_WITH_VARIABLES:append = " ${D}/init.d/06-create_overlay"

do_install:append () {
    install -m 0755 "${WORKDIR}/create_overlay" "${D}/init.d/06-create_overlay"
}
