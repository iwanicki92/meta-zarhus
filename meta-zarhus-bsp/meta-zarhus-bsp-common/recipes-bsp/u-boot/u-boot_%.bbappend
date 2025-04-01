FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'imagemagick-native', '', d)}"
SRC_URI += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'file://enable-splash.cfg', '', d)} \
    "

# U-Boot recipe doesn't have do_install tasks (and everything after)
# so it's easier to separate U-Boot logo task into another recipe.
# There is a problem that U-Boot doesn't respect RDEPENDS and doesn't build
# u-boot-logo recipe so I also added it to `base_files` RDEPENDS.
RDEPENDS:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'u-boot-logo', '', d)}"
