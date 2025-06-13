BOOT_A_UUID = "${BOOT_UUID}"
ROOT_A_UUID = "${ROOT_UUID}"
BOOT_B_UUID = "${@generate_uuid_from_sha(d, 'boot_b')}"
ROOT_B_UUID = "${@generate_uuid_from_sha(d, 'root_b')}"

ROOTFS_LABEL = "${OTAB_LABEL_ROOTFS_A}"
# Use override as it has higher priority
UKI_FILENAME:x86-64 = "zarhus_a.efi"
UKI_FILENAME_B = "zarhus_b.efi"
# should replace previous bootx64.efi with new one when copying
IMAGE_BOOT_FILES_label-${OTAB_LABEL_BOOT_B}:append = " \
    ${UKI_FILENAME_B};EFI/BOOT/bootx64.efi \
"

# Change root= to second rootfs
def get_second_cmdline(d):
    import re
    cmdline = d.getVar("UKI_CMDLINE")
    # ukify will trim multiple whitespace characters into one
    return " ".join(
        re.sub(
            r"root=.*?( |$)", fr"root=LABEL={d.getVar('OTAB_LABEL_ROOTFS_B')} ",
            cmdline
        ).split())

# If second cmdline is longer than first then add placeholder to first cmdline
# so it's at least as long as second one
python do_uki:prepend() {
    import bb
    # trim multiple whitespaces as that's what ukify does
    cmdline = " ".join(d.getVar('UKI_CMDLINE').split())
    second_cmdline = get_second_cmdline(d)
    if len(cmdline) < len(second_cmdline):
        placeholder = "placeholder="
        missing_length = len(second_cmdline) - len(cmdline) - len(placeholder)
        placeholder = placeholder + "0"*missing_length
        cmdline = f"{cmdline} {placeholder}"
        bb.debug(1, f"{cmdline=}")
        d.setVar('UKI_CMDLINE', cmdline)
}

# Copy UKI and replace cmdline. It can't be longer than original that's why we
# extend cmdline in first UKI if needed.
python do_second_uki() {
    import bb.process
    second_cmdline = get_second_cmdline(d)
    cmdline_path = f"{d.getVar('WORKDIR')}/second_cmdline"
    with open(cmdline_path, "w") as file:
        file.write(second_cmdline)
    deploy_dir = d.getVar('DEPLOY_DIR_IMAGE')
    first_uki = f"{deploy_dir}/{d.getVar('UKI_FILENAME')}"
    second_uki = f"{deploy_dir}/{d.getVar('UKI_FILENAME_B')}"

    # replace cmdline section in second UKI
    objcopy_cmd = f"{d.getVar('OBJCOPY')} --update-section .cmdline={cmdline_path} {second_uki}"
    bb.process.run(f"cp {first_uki} {second_uki}", shell=True)
    bb.debug(1, f"Creating second uki cmd: {objcopy_cmd}")
    bb.debug(1, f"Second cmdline contains: {second_cmdline}")
    bb.process.run(objcopy_cmd, shell=True)
}

addtask second_uki after do_uki before do_deploy do_image_complete do_image_wic
