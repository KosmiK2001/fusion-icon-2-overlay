# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Compiz Option code Generator"
HOMEPAGE="https://github.com/KosmiK2001/compiz-bcop"
SRC_URI="https://github.com/KosmiK2001/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-libs/libxslt
	virtual/pkgconfig
"

RDEPEND="
	dev-libs/libxslt
"

src_prepare() {
	default
	eautoreconf
}
