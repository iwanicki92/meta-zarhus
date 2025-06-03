FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "file://cms-sign.cfg"

# Install certificate at the target
RDEPENDS:${PN} += " otab-keys-sig"
