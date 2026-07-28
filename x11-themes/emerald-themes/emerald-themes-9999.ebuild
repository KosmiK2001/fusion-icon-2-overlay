# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="Emerald window decorator themes"
HOMEPAGE="https://github.com/KosmiK2001/emerald-themes"
EGIT_REPO_URI="https://github.com/KosmiK2001/${PN}.git"
EGIT_BRANCH="master"

LICENSE="GPL-2+ GPL-3+"
SLOT="0"
KEYWORDS=""

RDEPEND=">=x11-wm/emerald-0.8.12
	<x11-wm/emerald-0.9
"

src_prepare() {
	default
	eautoreconf
}
