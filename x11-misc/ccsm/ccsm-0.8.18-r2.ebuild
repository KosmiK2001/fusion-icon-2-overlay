EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_IN_SOURCE_BUILD=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_NO_WHEEL=1
DISTUTILS_USE_PEP517=no

inherit distutils-r1 gnome2-utils

DESCRIPTION="A graphical manager for CompizConfig Plugin (libcompizconfig)"
HOMEPAGE="https://github.com/KosmiK2001/ccsm"
SRC_URI="https://github.com/KosmiK2001/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk3"

RDEPEND="
	>=dev-python/compizconfig-python-0.8.12[${PYTHON_SINGLE_USEDEP}]
	<dev-python/compizconfig-python-0.9
	$(python_gen_cond_dep '
	dev-python/pycairo[${PYTHON_USEDEP}]
	')
	$(python_gen_cond_dep '
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	gnome-base/librsvg[introspection]
"

python_prepare_all() {
	if [[ -n "${LINGUAS+x}" ]] ; then
	for i in $(cd po ; echo *po | sed 's/\.po//g') ; do
		if ! has ${i} ${LINGUAS} ; then
	rm po/${i}.po || die
		fi
	done
	fi

	distutils-r1_python_prepare_all
}

python_configure_all() {
	DISTUTILS_ARGS=(
	build
	"--prefix=/usr"
	"--with-gtk=$(usex gtk3 3.0 2.0)"
	)
}

distutils-r1_python_install() {
	esetup.py install --root="${D}" --prefix=/usr --no-compile || die
	python_optimize
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
