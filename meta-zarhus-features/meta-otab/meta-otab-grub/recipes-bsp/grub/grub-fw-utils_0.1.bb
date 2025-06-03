DESCRIPTION = "Wrapper for grub-editenv which mimics fw_printenv and \
fw_setenv utilites from U-Boot"

LICENSE = "CLOSED"

SRC_URI = "file://fw_printenv"

RDEPENDS:${PN} = "grub-editenv"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/fw_printenv ${D}${bindir}/
    ln -s fw_printenv ${D}${bindir}/fw_setenv
}
