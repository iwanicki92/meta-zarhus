FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://setup-second-efi-entry.sh"

do_install:append() {
    # Add contents of setup-second-efi-entry.sh before 'efibootmgr --disk...'
    # as last entry added will be first to boot
    sed -i "/efibootmgr --disk/ {
    e cat '${WORKDIR}/setup-second-efi-entry.sh'
    N
    }" ${D}${libdir}/zarhus/setup-efi-entry.sh
    sed -i 's/--label "ZarhusOS"/--label "ZarhusOS A"/' ${D}${libdir}/zarhus/setup-efi-entry.sh
}
