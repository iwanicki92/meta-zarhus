SUMMARY = "Mimic fw_printenv and fw_setenv utilities from U-Boot"
DESCRIPTION = " \
    Script that mimics how fw_printenv and fw_setenv utilities from U-Boot \
    work. Used by otab script. \
"
HOMEPAGE = "https://docs.zarhus.com"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://fw_printenv"
RDEPENDS:${PN} = "efivar"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/fw_printenv ${D}${sbindir}/
    ln -s fw_printenv ${D}${sbindir}/fw_setenv
}
