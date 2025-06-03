SUMMARY = "Otab update signed keys"
SECTION = "support"

LICENSE = "CLOSED"

SRC_URI = " \
    file://${SWU_SIG_KEY_FILE} \
    file://${SWU_SIG_CERT_FILE} \
"

DEPENDS = "cpio-native openssl-native"

S = "${WORKDIR}"

RDEPENDS:${PN} = "swupdate"

# Install key and certificate
do_install() {
    install -d ${D}${OTAB_KEYS_DIR}
    install -m 0600 ${S}/${SWU_SIG_CERT_FILE} ${D}${OTAB_KEYS_DIR}
}

FILES:${PN} = " \
    ${OTAB_KEYS_DIR}/${SWU_SIG_CERT_FILE} \
"
