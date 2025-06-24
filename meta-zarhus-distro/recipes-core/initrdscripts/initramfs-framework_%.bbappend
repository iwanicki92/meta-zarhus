FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://shutdown/shutdown \
    file://shutdown/finish \
    file://shutdown/umount \
    file://shutdown/luks_close \
"
PACKAGES += "initramfs-module-shutdown initramfs-module-luks-close"

# nooelint: oelint.var.order.SUMMARY
SUMMARY:initramfs-module-shutdown = "initramfs support for shutdown hooks"
# nooelint: oelint.var.filesoverride
FILES:initramfs-module-shutdown = " \
    /shutdown \
    /shutdown.d/01-udev \
    /shutdown.d/90-umount \
    /shutdown.d/99-finish \
"
RDEPENDS:initramfs-module-shutdown = "${PN}-base kexec"

# nooelint: oelint.var.order.SUMMARY
SUMMARY:initramfs-module-luks-close = "initramfs support for closing luks partitions during shutdown"
# nooelint: oelint.var.filesoverride
FILES:initramfs-module-luks-close = "/shutdown.d/93-luks_close"
RDEPENDS:initramfs-module-luks-close = "${PN}-base cryptsetup"

do_install:append () {
    install -m 0755 "${WORKDIR}/shutdown/shutdown" "${D}/shutdown"
    install -d "${D}/shutdown.d"
    install -m 0755 "${WORKDIR}/udev" "${D}/shutdown.d/01-udev"
    install -m 0755 "${WORKDIR}/shutdown/umount" "${D}/shutdown.d/90-umount"
    install -m 0755 "${WORKDIR}/shutdown/luks_close" "${D}/shutdown.d/93-luks_close"
    install -m 0755 "${WORKDIR}/shutdown/finish" "${D}/shutdown.d/99-finish"
}
