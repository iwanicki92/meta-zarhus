# override default CMDLINE variable so it does not contain the rootfs related
# parameters
CMDLINE = "dwc_otg.lpm_enable=0 ${SERIAL}"
