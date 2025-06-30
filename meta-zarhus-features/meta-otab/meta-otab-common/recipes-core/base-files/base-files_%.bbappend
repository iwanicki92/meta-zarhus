FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

OTAB_FILES_WITH_VARIABLES = "${D}${sysconfdir}/fstab"

inherit otab_variables_postinstall

do_install:append() {
  install -m 0755 -d ${D}${OTAB_DATA_DIR}
}

FILES:${PN} += "${OTAB_DATA_DIR}"
