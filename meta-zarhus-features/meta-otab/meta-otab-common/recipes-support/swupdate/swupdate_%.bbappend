FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Disable swupdate systemd default service
SYSTEMD_AUTO_ENABLE = "disable"
