# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="GPU switch service: nouveau for boot, nvidia for X"
HOMEPAGE=""
SRC_URI=""
S="${WORKDIR}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	x11-drivers/nvidia-drivers
	x11-drivers/nvidia-kmod
"

src_install() {
	# GPU switch service
	insinto /etc/systemd/system
	doins "${FILESDIR}/gpu-switch.service"

	# GPU switch script
	dobin "${FILESDIR}/gpu-switch-to-nvidia"

	# switch-opengl script
	dobin "${FILESDIR}/switch-opengl"

	# lightdm override
	insinto /etc/systemd/system/lightdm.service.d
	doins "${FILESDIR}/lightdm-override.conf"
}

pkg_postinst() {
	elog "GPU switch service installed."
	elog ""
	elog "Boot flow: nouveau (plymouth) → gpu-switch → nvidia → lightdm"
	elog ""
	elog "Commands:"
	elog "  switch-opengl          - show current OpenGL provider"
	elog "  switch-opengl nvidia   - switch to nvidia"
	elog "  switch-opengl mesa     - switch to mesa"
	elog ""
	elog "To enable: systemctl enable gpu-switch.service"
	elog ""
	elog "Add to /etc/default/grub:"
	elog "  GRUB_CMDLINE_LINUX_DEFAULT=\"... mitigations=off pci=realloc pci=nocrs\""
}
