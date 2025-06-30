FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

OTAB_FILES_WITH_VARIABLES:append = " ${D}${sysconfdir}/cukinia/conf.d/encryption.conf"
