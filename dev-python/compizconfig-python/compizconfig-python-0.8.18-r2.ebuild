# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit autotools python-single-r1

DESCRIPTION="Python bindings for libraries/plugins for compizconfig-settings"
HOMEPAGE="https://github.com/KosmiK2001/compizconfig-python"
SRC_URI="https://github.com/KosmiK2001/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/cython[${PYTHON_USEDEP}]
	')
	>=dev-libs/glib-2.6
	>=x11-libs/libcompizconfig-0.6.99
	<x11-libs/libcompizconfig-0.9
	virtual/pkgconfig
"

RDEPEND="${DEPEND}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--with-python=${EPYTHON}
}

src_compile() {
	emake
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
