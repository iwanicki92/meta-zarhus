SUMMARY = "Otab update encryption keys"
SECTION = "support"

LICENSE = "CLOSED"

DEPENDS = "cpio-native openssl-native"

S = "${WORKDIR}"

RDEPENDS:${PN} = "swupdate"

# Create file used to decrypt image
do_install() {
    echo "${SWUPDATE_ENC_KEY} ${SWUPDATE_ENC_IV}" > enc.key
    install -d ${D}${OTAB_KEYS_DIR}
    install -m 0600 ${S}/enc.key ${D}${OTAB_KEYS_DIR}
}

FILES:${PN} += "${OTAB_KEYS_DIR}/enc.key"
