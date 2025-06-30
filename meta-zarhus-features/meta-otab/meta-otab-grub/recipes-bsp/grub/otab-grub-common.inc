FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS:append:class-target = " ${PN}-native"
SRC_URI:append = " \
    file://grub.cfg \
"

OTAB_FILES_WITH_VARIABLES = "${WORKDIR}/grub.cfg"

inherit otab_variables_preinstall

do_deploy:append:class-target() {
    # create empty environment file
    # installation into EFI dir is made using wic .wks file, through
    # IMAGE_BOOT_FILES variable
    rm -f grubenv
    grub-editenv grubenv create
    grub-editenv grubenv set otab_part_default=2

    # If the variable is unset or empty the serial console will be disabled
    if [ ! -z "${OTAB_SERIAL_CONSOLE}" ]; then
        grub-editenv grubenv set otab_serial_default=${OTAB_SERIAL_CONSOLE}
    fi

    # provide custom grub config
    install -m 644 ${B}/grubenv ${DEPLOYDIR}
    install -m 644 ${WORKDIR}/grub.cfg ${DEPLOYDIR}
}

FILES:${PN} += "${bindir}/fw_printenv ${bindir}/fw_setenv"
