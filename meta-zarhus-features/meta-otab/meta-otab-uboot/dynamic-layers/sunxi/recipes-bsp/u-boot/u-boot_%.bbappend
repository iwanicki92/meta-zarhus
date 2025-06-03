FILESEXTRAPATHS:prepend:sunxi := "${THISDIR}/files:"

SRC_URI:append:sunxi = " file://boot.cmd.in"

OTAB_FILES_WITH_VARIABLES = "${WORKDIR}/boot.cmd.in"

UBOOT_ENV_SRC:sunxi = "boot.cmd.in"

inherit otab-variables-preinstall

do_compile:append:sunxi() {
    ${B}/tools/mkimage -C none -A arm -T script -d ${WORKDIR}/boot.cmd.in ${WORKDIR}/${UBOOT_ENV_BINARY}
}
