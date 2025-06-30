FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:append() {
    echo 'efivarfs /sys/firmware/efi/efivars efivarfs rw,nosuid,nodev,noexec,nofail 0 0' \
        >> ${D}${sysconfdir}/fstab
}
