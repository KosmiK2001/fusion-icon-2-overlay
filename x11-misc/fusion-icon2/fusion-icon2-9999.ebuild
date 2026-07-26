# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Fusion Icon 2 - system tray for switching Compiz window managers"
HOMEPAGE="https://github.com/KosmiK2001/fusion-icon-2"
EGIT_REPO_URI="https://github.com/KosmiK2001/fusion-icon-2.git"
EGIT_BRANCH="main"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-cpp/gtkmm:3.0"
RDEPEND="${DEPEND}"

src_compile() {
	cd "${S}/src"
	emake
}

src_install() {
	dobin "${S}/src/fusion_icon.bin"
}
