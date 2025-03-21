FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'imagemagick-native', '', d)}"
SRC_URI += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'file://enable-splash.cfg', '', d)} \
    "

# For some reason it doesn't run this recipe
RDEPENDS:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'u-boot-logo', '', d)}"
