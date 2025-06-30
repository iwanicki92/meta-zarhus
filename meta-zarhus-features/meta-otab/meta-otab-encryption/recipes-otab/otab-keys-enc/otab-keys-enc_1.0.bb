SUMMARY = "Otab update encryption keys"
DESCRIPTION = "${SUMMARY}"
HOMEPAGE = "https://docs.zarhus.com"
SECTION = "support"
LICENSE = "CLOSED"

DEPENDS = "cpio-native openssl-native"
SRC_URI = ""
S = "${WORKDIR}"
FILES:${PN} += "${OTAB_KEYS_DIR}/enc.key"
RDEPENDS:${PN} = "swupdate"

# Create file used to decrypt image
do_install() {
    echo "${SWUPDATE_ENC_KEY} ${SWUPDATE_ENC_IV}" > enc.key
    install -d ${D}${OTAB_KEYS_DIR}
    install -m 0600 ${S}/enc.key ${D}${OTAB_KEYS_DIR}
}
