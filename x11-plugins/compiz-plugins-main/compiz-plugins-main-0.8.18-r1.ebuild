# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools gnome2-utils

DESCRIPTION="Compiz Window Manager: Plugins"
HOMEPAGE="https://github.com/KosmiK2001/compiz-plugins-main"
SRC_URI="https://github.com/KosmiK2001/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	gnome-base/librsvg
	virtual/jpeg:0
	virtual/glu
	>=x11-libs/compiz-bcop-0.7.3
	<x11-libs/compiz-bcop-0.9
	>=x11-wm/compiz-0.8
	<x11-wm/compiz-0.9
	x11-libs/cairo[X]
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_prepare() {
	default
	eapply "${FILESDIR}/stdlib-fix.patch"
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
