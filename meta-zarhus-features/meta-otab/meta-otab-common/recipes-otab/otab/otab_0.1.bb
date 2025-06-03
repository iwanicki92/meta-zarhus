DESCRIPTION = "OTA A/B utility manager for SWUpdate-based OTA implementation"

LICENSE = "CLOSED"

SRC_URI = "file://otab \
           file://otab-variables \
           file://otab-confirm.service \
           file://otab-polling.service \
          "
# with every build fetch all SRC_URI to detect changes
do_fetch[nostamp] = "1"

OTAB_FILES_WITH_VARIABLES = "${WORKDIR}/otab-variables"

inherit otab-variables-preinstall systemd

RDEPENDS:${PN} = "swupdate e2fsprogs-tune2fs"

SYSTEMD_PACKAGES = "${PN} ${PN}-polling"
SYSTEMD_SERVICE:${PN} = " \
    otab-confirm.service \
"
SYSTEMD_SERVICE:${PN}-polling = " \
    otab-polling.service \
"

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_AUTO_ENABLE:${PN}-polling = "enable"

PACKAGES =+ "${PN}-polling"

do_install() {
    install -d ${D}${sbindir}
    install -m 0744 ${WORKDIR}/otab ${D}${sbindir}
    install -m 0744 ${WORKDIR}/otab-variables ${D}${sbindir}
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/otab-confirm.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/otab-polling.service ${D}${systemd_unitdir}/system/
}

FILES:${PN} += " \
    ${systemd_unitdir}/system/otab-confirm.service \
"

FILES:${PN}-polling += " \
    ${systemd_unitdir}/system/otab-polling.service \
"
