FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://initramfs.cfg \
    file://overlay.cfg \
"
