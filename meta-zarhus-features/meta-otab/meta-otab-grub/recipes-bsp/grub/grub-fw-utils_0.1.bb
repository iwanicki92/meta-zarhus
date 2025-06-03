SUMMARY = "Wrapper for grub-editenv"
DESCRIPTION = " \
    Wrapper for grub-editenv which mimics fw_printenv and \
    fw_setenv utilities from U-Boot \
"
HOMEPAGE = "https://docs.zarhus.com"
LICENSE = "CLOSED"

SRC_URI = "file://fw_printenv"
RDEPENDS:${PN} = "grub-editenv"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/fw_printenv ${D}${bindir}/
    ln -s fw_printenv ${D}${bindir}/fw_setenv
}
