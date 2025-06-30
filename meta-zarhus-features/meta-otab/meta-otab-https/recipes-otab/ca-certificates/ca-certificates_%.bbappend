SRC_URI += " \
    file://${OTAB_SERVER_CERT_FILE} \
"

# Trust the server certificate
do_install:append() {
    echo "${OTAB_SERVER_CERT_DIR_TARGET}/${OTAB_SERVER_CERT_FILE}" >> ${D}${sysconfdir}/ca-certificates.conf
    install -d ${D}${datadir}/ca-certificates/${OTAB_SERVER_CERT_DIR_TARGET}
    install -m 0600 ${WORKDIR}/${OTAB_SERVER_CERT_FILE} ${D}${datadir}/ca-certificates/${OTAB_SERVER_CERT_DIR_TARGET}
}
