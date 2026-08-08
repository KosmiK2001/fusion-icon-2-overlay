# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MY_PV="r2"
DESCRIPTION="Kernel driver for ASUS OLED USB display (G1/G2, G50)"
HOMEPAGE="https://github.com/epw/asus_oled"
SRC_URI="https://github.com/epw/asus_oled/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/asus_oled-master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

PATCHES=(
	"${FILESDIR}/0001-fix-kernel-6.12.patch"
)

pkg_pretend() {
	if ! linux_config_exists; then
		ewarn "Cannot check kernel config — module will be built anyway"
	fi
}

src_compile() {
	local modlist=( asus_oled=extra )
	local modargs=( KDIR="${KV_DIR}" )
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	# Install helper scripts
	dodoc README
}

pkg_postinst() {
	elog "To load the module manually:"
	elog "  modprobe asus_oled"
	elog ""
	elog "To control the OLED display:"
	elog "  echo 0 > /sys/class/asus_oled/oled_1/enabled  # turn off"
	elog "  echo 1 > /sys/class/asus_oled/oled_1/enabled  # turn on"
	elog ""
	elog "For automatic loading, add 'asus_oled' to:"
	elog "  /etc/modules-load.d/oled.conf"
}
