UKI_CMDLINE:append = " \
    rd.luks.encrypt=PARTLABEL=${OTAB_LABEL_ROOTFS_A},PARTLABEL=${OTAB_LABEL_ROOTFS_B},PARTLABEL=${OTAB_LABEL_ROOTFS_OVERLAY} \
"

# Change root= & rd.luks.rootfs= to second rootfs
def get_second_cmdline(d):
    import re
    cmdline = d.getVar("UKI_CMDLINE")
    cmdline = re.sub(
        r"root=.*?( |$)",
        fr"root=LABEL={d.getVar('OTAB_LABEL_ROOTFS_B')} ",
        cmdline
    )
    cmdline = re.sub(
        r"rd\.luks\.rootfs=.*?( |$)",
        fr"rd.luks.rootfs=PARTLABEL={d.getVar('OTAB_LABEL_ROOTFS_B')} ",
        cmdline
    )
    # ukify will trim multiple whitespace characters into one
    return " ".join(cmdline.split())
