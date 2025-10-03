FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://encryption.conf \
    file://encryption-common.sh \
"
FILES:${PN} += " \
    ${sysconfdir}/cukinia/conf.d/encryption.conf \
    ${sysconfdir}/cukinia/conf.d/encryption-common.sh \
"

RDEPENDS:${PN} += " jq"

do_install:append() {
    install -d "${D}${sysconfdir}/cukinia/conf.d"
    install -m "0644" "${WORKDIR}/encryption.conf" "${D}${sysconfdir}/cukinia/conf.d/"
    install -m "0644" "${WORKDIR}/encryption-common.sh" "${D}${sysconfdir}/cukinia/conf.d/"
}
