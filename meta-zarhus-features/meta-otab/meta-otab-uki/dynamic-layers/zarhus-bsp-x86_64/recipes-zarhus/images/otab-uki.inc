BOOT_A_UUID = "${BOOT_UUID}"
ROOT_A_UUID = "${ROOT_UUID}"

BOOT_LABEL = "${OTAB_LABEL_BOOT_A}"
ROOTFS_LABEL = "${OTAB_LABEL_ROOTFS_A}"
# Use override as it has higher priority
UKI_FILENAME:x86-64 = "zarhus_a.efi"

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
