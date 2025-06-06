BOOT_A_UUID = "${BOOT_UUID}"
ROOT_A_UUID = "${ROOT_UUID}"
BOOT_B_UUID = "${@generate_uuid_from_sha(d, 'boot_b')}"
ROOT_B_UUID = "${@generate_uuid_from_sha(d, 'root_b')}"

ROOTFS_LABEL = "${OTAB_LABEL_ROOTFS_A}"
UKI_FILENAME = "zarhus_a.efi"
UKI_FILENAME_B = "zarhus_b.efi"
# should replace previous bootx64.efi with new one when copying
IMAGE_BOOT_FILES_label-${OTAB_LABEL_BOOT_B}:append = " \
    ${UKI_FILENAME_B};EFI/BOOT/bootx64.efi \
"

# Change root= to second rootfs
def get_second_cmdline(d):
    import re
    cmdline = d.getVar("UKI_CMDLINE")
    return re.sub("root=.*? ", f"root=LABEL={d.getVar('OTAB_LABEL_ROOTFS_B')} ", cmdline)

# Create second UKI by creating first with longer cmdline and then replacing
# cmdline in copy with shorter cmdline (as we can't easily resize section)
python do_uki:prepend() {
    cmdline = d.getVar('UKI_CMDLINE')
    second_cmdline = get_second_cmdline(d)
    # use second cmdline if it's longer
    if len(cmdline) < len(second_cmdline):
        d.setVar('UKI_CMDLINE', second_cmdline)
}

python do_second_uki() {
    import bb.process
    cmdline = d.getVar('UKI_CMDLINE')
    second_cmdline = get_second_cmdline(d)
    # second UKI will contain smaller of cmdlines or 'second_cmdline' if equal
    if len(second_cmdline) <= len(cmdline):
        cmdline = second_cmdline
    cmdline_path = f"{d.getVar('WORKDIR')}/second_cmdline"
    with open(cmdline_path, "w") as file:
        file.write(cmdline)
    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    first_uki = f"{deploy_dir}/{d.getVar('UKI_FILENAME')}"
    second_uki = f"{deploy_dir}/{d.getVar('UKI_FILENAME_B')}"

    # replace cmdline section in second UKI
    objcopy_cmd = f"{d.getVar('OBJCOPY')} --update-section .cmdline={cmdline_path} {second_uki}"
    bb.process.run(f"cp {first_uki} {second_uki}", shell=True)
    bb.debug(f"Creating second uki cmd: {objcopy_cmd}")
    bb.process.run(objcopy_cmd, shell=True)
}

addtask second_uki after do_uki before do_deploy do_image_complete do_image_wic
