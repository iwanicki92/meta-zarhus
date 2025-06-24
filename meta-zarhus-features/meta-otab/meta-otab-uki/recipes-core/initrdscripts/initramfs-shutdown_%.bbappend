RDEPENDS:${PN}:append = " binutils"

# depending on currently mounted '/boot' it'll be zarhus_a.efi or zarhus_b.efi
INITRAMFS_PATH ??= "/boot/efi/boot/bootx64.efi"
INITRAMFS_EXTRACT_CMD ??= "objcopy --dump-section .initrd=/tmp/initrd ${INITRAMFS_PATH} $(mktemp) && gunzip -c /tmp/initrd"
