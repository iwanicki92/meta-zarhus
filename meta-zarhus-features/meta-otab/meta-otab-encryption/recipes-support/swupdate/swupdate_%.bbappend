FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "file://encryption.cfg"

# Install decryption key at the target
RDEPENDS:${PN} += "otab-keys-enc"
