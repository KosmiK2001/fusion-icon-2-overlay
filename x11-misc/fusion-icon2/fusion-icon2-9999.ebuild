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
IUSE="+upx"

DEPEND="dev-cpp/gtkmm:3.0
	gnome-base/librsvg
	media-gfx/imagemagick"
RDEPEND="${DEPEND}
	gnome-base/librsvg"

src_compile() {
	cd "${S}/src"
	emake ICON_DIR="/usr/share/fusion-icon2"
}

src_install() {
	local sizes="16 22 24 32 48 64 128 256"

	# Генерируем PNG из SVG для всех размеров
	for size in ${sizes}; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		rsvg-convert -w ${size} -h ${size} "${S}/src/icons/marco.svg" -o "${T}/marco-${size}.png"
		doins "${T}/marco-${size}.png"
		rsvg-convert -w ${size} -h ${size} "${S}/src/icons/nvidia.svg" -o "${T}/nvidia-${size}.png"
		doins "${T}/nvidia-${size}.png"
	done

	# SVG и фиксированная иконка приложения
	insinto /usr/share/fusion-icon2
	doins "${S}/src/icons/marco.svg"
	doins "${S}/src/icons/nvidia.svg"
	doins "${S}/src/icons/fusion-icon.png"

	# Desktop файл
	insinto /usr/share/applications
	doins "${S}/src/fusion-icon2.desktop"

	# Бинарник
	dobin "${S}/src/fusion-icon2"
}
