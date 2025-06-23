FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://otab.conf"
FILES:${PN} += "${sysconfdir}/cukinia/conf.d/otab.conf"

inherit otab_variables_postinstall
OTAB_FILES_WITH_VARIABLES:append = " ${D}${sysconfdir}/cukinia/conf.d/otab.conf"

do_install:append() {
    install -d "${D}${sysconfdir}/cukinia/conf.d"
    install -m "0644" "${WORKDIR}/otab.conf" "${D}${sysconfdir}/cukinia/conf.d/"
}
