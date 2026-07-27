# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools gnome2-utils

DESCRIPTION="Compiz Window Manager: Extra Plugins"
HOMEPAGE="https://gitlab.com/compiz"
SRC_URI="https://gitlab.com/compiz/${PN}/uploads/b53eb95252331d53b42231778f55de44/${P/-r1/}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify"

RDEPEND="
	>=x11-libs/compiz-bcop-0.7.3
	<x11-libs/compiz-bcop-0.9
	>=x11-plugins/compiz-plugins-main-0.8
	<x11-plugins/compiz-plugins-main-0.9
	>=x11-wm/compiz-0.8
	<x11-wm/compiz-0.9
	virtual/jpeg:0
	libnotify? ( x11-libs/libnotify )
	x11-libs/cairo[X]
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.15
	virtual/pkgconfig
"

S="${WORKDIR}/${PN}-0.8.18"

src_prepare() {
	default

	# Fix missing stdlib.h include in wallpaper.c (RAND_MAX undeclared)
	eapply "${FILESDIR}/stdlib-fix.patch"

	# 3D Windows plugin performance optimizations
	eapply "${FILESDIR}/3d-performance.patch"

	eautoreconf
}

src_configure() {
	econf \
		--enable-fast-install \
		--disable-static
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}

compiz_icon_cache_update() {
	local dir="${EROOT}/usr/share/compiz/icons/hicolor"
	local updater="${EROOT}/usr/bin/gtk-update-icon-cache"
	if [[ -n "$(ls "$dir")" ]]; then
		"${updater}" -q -f -t "${dir}"
		rv=$?
		if [[ ! $rv -eq 0 ]] ; then
			debug-print "Updating cache failed on ${dir}"
			fails+=( "${dir}" )
			retval=2
		fi
	elif [[ $(ls "${dir}") = "icon-theme.cache" ]]; then
		rm "${dir}/icon-theme.cache"
	fi
	if [[ -z $(ls "${dir}") ]]; then
		rmdir "${dir}"
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	compiz_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	compiz_icon_cache_update
}
