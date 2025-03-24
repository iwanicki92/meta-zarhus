FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LOAD_ADDR ?= "\$loadaddr"
# mmc 1 partition 9
DEVPART ?= "1:9"
EXTRA_OEMAKE:append:rk3566 = " \
        BL31=${DEPLOY_DIR_IMAGE}/bl31-rk3566.elf \
        ROCKCHIP_TPL=${DEPLOY_DIR_IMAGE}/ddr-rk3566.bin \
"
INIT_FIRMWARE_DEPENDS:rk3566 = " rockchip-rkbin:do_deploy"
do_compile[depends] += "${INIT_FIRMWARE_DEPENDS}"

SRC_URI:append = " \
    file://orangepi-cm4-base-rk3566_defconfig \
    file://rk3566-orangepi-cm4-base.dts \
    file://rk3566-orangepi-cm4-base-u-boot.dtsi \
    file://rk3566-orangepi-cm4.dtsi \
    file://0001-vop2_support.patch \
    "
SRC_URI:append:radxa-cm3 = " ${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'file://enable-hdmi.cfg', '', d)}"

do_configure:prepend() {
    install -m 644 "${WORKDIR}/orangepi-cm4-base-rk3566_defconfig" "${S}/configs"
    install -m 644 "${WORKDIR}/rk3566-orangepi-cm4-base.dts" "${S}/arch/arm/dts"
    install -m 644 "${WORKDIR}/rk3566-orangepi-cm4.dtsi" "${S}/arch/arm/dts"
    install -m 644 "${WORKDIR}/rk3566-orangepi-cm4-base-u-boot.dtsi" "${S}/arch/arm/dts"
    echo 'dtb-$(CONFIG_ROCKCHIP_RK3568) += rk3566-orangepi-cm4.dtb' >> "${S}/arch/arm/dts/Makefile"
}

do_configure:append() {
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'splash', 'yes', 'no', d)}" = "yes" ]; then
        sed -i '/#define CFG_EXTRA_ENV_SETTINGS\s*\\/a "splashsource=mmc_fs\\0" \\' "${S}/include/configs/rk3568_common.h"
        sed -i '/#define CFG_EXTRA_ENV_SETTINGS\s*\\/a "splashfile=/boot/logo.bmp\\0" \\' "${S}/include/configs/rk3568_common.h"
        sed -i "/#define CFG_EXTRA_ENV_SETTINGS\s*\\\\/a \"splashimage=${LOAD_ADDR}\\\\0\" \\\\" "${S}/include/configs/rk3568_common.h"
        sed -i "/#define CFG_EXTRA_ENV_SETTINGS\s*\\\\/a \"splashdevpart=${DEVPART}\\\\0\" \\\\" "${S}/include/configs/rk3568_common.h"
    fi
}
