FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS:append = " efivar"

SRC_URI:remove = "git://github.com/sbabic/swupdate.git;protocol=https;branch=${SRCBRANCH}"
SRC_URI:append = " git://github.com/3mdeb/swupdate.git;protocol=https;branch=${SRCBRANCH}"
SRCBRANCH = "efivar"
# nooelint: oelint.append.protvars
SRCREV = "7dd732c02ee1e682b88ddb155e12d809212d4112"
