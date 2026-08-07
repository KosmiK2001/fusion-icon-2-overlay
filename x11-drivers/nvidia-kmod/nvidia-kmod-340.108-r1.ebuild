# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-mod-r1 readme.gentoo-r1 unpacker

MODULES_KERNEL_MAX=6.12
NV_URI="https://download.nvidia.com/XFree86/"

DESCRIPTION="NVIDIA Accelerated Graphic Driver - kernel module"
HOMEPAGE="https://www.nvidia.com/download/index.aspx"
SRC_URI="
	amd64? ( ${NV_URI}Linux-x86_64/${PV}/NVIDIA-Linux-x86_64-${PV}.run )
	x86? ( ${NV_URI}Linux-x86/${PV}/NVIDIA-Linux-x86-${PV}.run )
"

LICENSE="NVIDIA-r2"
SLOT="0/${PV%%.*}"
KEYWORDS="-* amd64 x86"

DEPEND="acct-group/video"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}/0001-backport-error-on-unknown-conftests.patch"
	"${FILESDIR}/0002-backport-error-on-unknown-conftests-uvm-part.patch"
	"${FILESDIR}/0009-backport-drm_driver_has_legacy_dev_list-changes-from.patch"
	"${FILESDIR}/0010-backport-drm_gem_object_get-changes-from-418.30.patch"
	"${FILESDIR}/0014-backport-nv_proc_ops_t-nv_timeval-changes-from-440.8.patch"
	"${FILESDIR}/0015-drm_legacy_pci_init-was-moved-to-drm-drm_legacy.h.patch"
	"${FILESDIR}/0016-backport-asm-pgtable_types.h-changes-from-390.138.patch"
	"${FILESDIR}/0017-backport-linux-ioctl32.h-changes-from-450.51.patch"
	"${FILESDIR}/0018-backport-nv_vmalloc-changes-from-450.57.patch"
	"${FILESDIR}/0019-work-around-mmap_-sem-lock-rename.patch"
	"${FILESDIR}/0020-work-around-mmap_-sem-lock-rename-uvm-part.patch"
	"${FILESDIR}/0021-backport-get_user_pages_remote-changes-from-455.23.0.patch"
	"${FILESDIR}/0022-backport-vga_tryget-changes-from-455.23.04.patch"
	"${FILESDIR}/0023-backport-drm_driver_has_gem_free_object-changes-from.patch"
	"${FILESDIR}/0024-backport-drm_prime_pages_to_sg_has_drm_device_arg-ch.patch"
	"${FILESDIR}/0025-check-for-drm_pci_init.patch"
	"${FILESDIR}/0026-import-drm_legacy_pci_init-exit-from-src-linux-5.9.1.patch"
	"${FILESDIR}/0027-add-static-and-nv_-prefix-to-copied-drm-legacy-bits.patch"
	"${FILESDIR}/0028-backport-asm-kmap_types.h-changes-from-460.32.03.patch"
	"${FILESDIR}/0029-backport-drm_driver_has_gem_prime_callbacks-changes-v2.patch"
	"${FILESDIR}/0030-skip-list-operations-if-drm_device.legacy_dev_list-i.patch"
	"${FILESDIR}/0031-backport-set_current_state-changes-from-470.63.01.patch"
	"${FILESDIR}/0032-backport-drm_device_has_pdev-changes-from-470.63.01-v2.patch"
	"${FILESDIR}/0033-check-for-member-agp-in-struct-drm_device.patch"
	"${FILESDIR}/0034-backport-stdarg.h-changes-from-470.82.00.patch"
	"${FILESDIR}/0035-backport-pde_data-changes-from-470.103.01.patch"
	"${FILESDIR}/0036-backport-pci-dma-changes-from-470.129.06.patch"
	"${FILESDIR}/0037-backport-acpi_bus_get_device-changes-from-470.129.06-v2.patch"
	"${FILESDIR}/0038-backport-acpi-changes-from-390.157-v2.patch"
	"${FILESDIR}/0039-backport-acpi_op_remove-changes-from-470.182.03.patch"
	"${FILESDIR}/0040-backport-vm_area_struct_has_const_vm_flags-changes-f-v2.patch"
	"${FILESDIR}/0041-backport-get_user_pages-changes-from-418.30.patch"
	"${FILESDIR}/0042-backport-get_user_pages-changes-from-520.56.06.patch"
	"${FILESDIR}/0043-backport-get_user_pages-changes-from-525.53.patch"
	"${FILESDIR}/0044-backport-get_user_pages-changes-from-535.86.05.patch"
	"${FILESDIR}/0045-backport-asm-page.h-changes-from-470.223.02.patch"
	"${FILESDIR}/0046-backport-drm_gem_prime_handle_to_fd-changes-from-470-v2.patch"
	"${FILESDIR}/0047-refuse-to-load-legacy-module-if-IBT-is-enabled.patch"
	"${FILESDIR}/0048-backport-nv_get_kern_phys_address-changes-from-555.4.patch"
	"${FILESDIR}/0049-fix-more-warnings.patch"
	"${FILESDIR}/0050-fix-more-uvm-warnings-v2.patch"
	"${FILESDIR}/0051-build-without-Wsign-compare.patch"
	"${FILESDIR}/0052-backport-cmd_symlink-changes-from-550.142.patch"
	"${FILESDIR}/0064-backport-drm_driver_has_date-from-570.124.04-v2.patch"
)

src_compile() {
	local modlist=( nvidia=video:kernel )
	local modargs=(
		IGNORE_CC_MISMATCH=yes NV_VERBOSE=1
		SYSOUT="${KV_OUT_DIR}" SYSSRC="${KV_DIR}"
	)
	use amd64 && modargs+=( ARCH=x86_64 )
	use x86 && modargs+=( ARCH=i386 )

	linux-mod-r1_src_compile
}

src_install() {
	local DOCS=()
	local DISABLE_AUTOFORMATTING="yes"
	local DOC_CONTENTS="\
Trusted users should be in the 'video' group to use NVIDIA devices.
You can add yourself by using: gpasswd -a my-user video

See '${EPREFIX}/etc/modprobe.d/nvidia.conf' for modules options."
	readme.gentoo_create_doc

	linux-mod-r1_src_install

	insinto /etc/modprobe.d
	newins "${FILESDIR}"/nvidia.modprobe nvidia.conf
}

pkg_preinst() {
	# set video group id based on live system (bug #491414)
	local g=$(getent group video | cut -d: -f3)
	[[ ${g} =~ ^[0-9]+$ ]] || die "Failed to determine video group id (got '${g}')"
	sed -i "s/@VIDEOGID@/${g}/" "${ED}"/etc/modprobe.d/nvidia.conf || die
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst

	readme.gentoo_print_elog
}
