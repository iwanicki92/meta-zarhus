SUMMARY = "Unpack initramfs before shutdown to /run/initramfs"
HOMEPAGE = "https://docs.zarhus.com"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://initramfs-restore file://initramfs-shutdown.service"

FILES:${PN} += " \
    ${libdir}/initramfs/initramfs-restore \
    ${systemd_system_unitdir}/initramfs-shutdown.service \
"

RDEPENDS:${PN} = "cpio"

INITRAMFS_PATH ??= "/boot/${INITRAMFS_IMAGE_NAME}.cpio.gz"
INITRAMFS_EXTRACT_CMD ??= "gunzip -c '${INITRAMFS_PATH}'"

inherit systemd

SYSTEMD_SERVICE:${PN} = "initramfs-shutdown.service"

replace_vars() {
    escaped="$(echo "${INITRAMFS_EXTRACT_CMD}" | sed -e 's/[&\\/]/\\&/g; s/$/\\/' -e '$s/\\$//')"
    sed -i "s/<INITRAMFS_EXTRACT_CMD>/${escaped}/g" "${D}${libdir}/initramfs/initramfs-restore"
}

do_install(){
    install -d "${D}${libdir}/initramfs"
    install -m 0744 "${WORKDIR}/initramfs-restore" "${D}${libdir}/initramfs/"
    replace_vars

    install -d "${D}${systemd_system_unitdir}"
    install -m 0644 "${WORKDIR}/initramfs-shutdown.service" "${D}${systemd_system_unitdir}/"
}
