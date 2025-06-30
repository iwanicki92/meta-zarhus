SUMMARY = "OTA A/B utility manager for SWUpdate-based OTA implementation"
DESCRIPTION = "${SUMMARY}"
HOMEPAGE = "https://docs.zarhus.com"
LICENSE = "CLOSED"

SRC_URI = " \
    file://otab \
    file://otab-variables \
    file://otab-confirm.service \
    file://otab-polling.service \
"

OTAB_FILES_WITH_VARIABLES = "${WORKDIR}/otab-variables"

inherit otab_variables_preinstall systemd

PACKAGES =+ "${PN}-polling"
FILES:${PN} += "${systemd_unitdir}/system/otab-confirm.service"
FILES:${PN}-polling += "${systemd_unitdir}/system/otab-polling.service"
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

do_install() {
    install -d ${D}${sbindir}
    install -m 0744 ${WORKDIR}/otab ${D}${sbindir}
    install -m 0744 ${WORKDIR}/otab-variables ${D}${sbindir}
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/otab-confirm.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/otab-polling.service ${D}${systemd_unitdir}/system/
}
