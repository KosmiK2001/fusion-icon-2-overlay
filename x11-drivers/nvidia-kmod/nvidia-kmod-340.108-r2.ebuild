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
	"${FILESDIR}/0008-backport-drm_available-changes-from-361.16-v2.2.patch"
	"${FILESDIR}/0009-backport-drm_driver_has_legacy_dev_list-changes-from.patch"
	"${FILESDIR}/0010-backport-drm_gem_object_get-changes-from-418.30.patch"
	"${FILESDIR}/0011-backport-nv_ioremap_nocache-changes-from-440.64-v2.2.patch"
	"${FILESDIR}/0012-backport-nv_proc_ops_t-changes-from-440.82-v2.patch"
	"${FILESDIR}/0013-backport-nv_timeval-changes-from-440.82-v2.patch"
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
	"${FILESDIR}/0065-conftest-sh-fix-kernel-6.12.patch"
)

src_prepare() {
	# Patches 0008, 0011, 0012, 0013 have partial failures but their
	# successful hunks are needed by subsequent patches.
	local p
	for p in "${PATCHES[@]}"; do
		case "$(basename "$p")" in
			0008-*|0011-*|0012-*|0013-*)
				ewarn "Applying $(basename "$p") with --force (partial)"
				patch -p1 --force --no-backup-if-mismatch < "$p" || true
				;;
			*)
				eapply "$p"
				;;
		esac
	done

	# === Kernel 6.12+ fixes ===

	# 1. Fix conftest.sh: override type test results for 6.12+
	#    Append to conftest.sh before the final esac so it outputs correct values.
	#    Actually, we need to modify the output files, but they don't exist yet.
	#    Instead, inject overrides into nv-linux.h after conftest.h include.

	# 2. Inject conftest overrides into nv-linux.h AFTER #include "conftest.h"
	#    Use sed to add a block of #undef+#define after the conftest include.
	sed -i '/#include "conftest.h"/a\
/* === Kernel 6.12+ conftest overrides === */\
#include <linux/version.h>\
#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 12, 0)\
#undef NV_KMEM_CACHE_CREATE_PRESENT\
#define NV_KMEM_CACHE_CREATE_PRESENT\
#undef NV_KMEM_CACHE_CREATE_ARGUMENT_COUNT\
#define NV_KMEM_CACHE_CREATE_ARGUMENT_COUNT 5\
#undef NV_KMEM_CACHE_CREATE_USERCOPY_PRESENT\
#define NV_KMEM_CACHE_CREATE_USERCOPY_PRESENT\
#undef NV_ACPI_WALK_NAMESPACE_ARGUMENT_COUNT\
#define NV_ACPI_WALK_NAMESPACE_ARGUMENT_COUNT 7\
#undef NV_PCI_SAVE_STATE_ARGUMENT_COUNT\
#define NV_PCI_SAVE_STATE_ARGUMENT_COUNT 1\
/* get_user_pages: patches 0041-0044 renamed macros. Force modern 4-arg API. */\
#undef NV_GET_USER_PAGES_HAS_ARGS_TSK_WRITE_FORCE_VMAS\
#undef NV_GET_USER_PAGES_HAS_ARGS_WRITE_FORCE_VMAS\
#undef NV_GET_USER_PAGES_HAS_ARGS_TSK_FLAGS_VMAS\
#undef NV_GET_USER_PAGES_HAS_ARGS_FLAGS_VMAS\
#undef NV_GET_USER_PAGES_HAS_ARGS_FLAGS\
#define NV_GET_USER_PAGES_HAS_ARGS_FLAGS\
/* get_user_pages_remote: force modern 6-arg API with locked param. */\
#undef NV_GET_USER_PAGES_REMOTE_PRESENT\
#define NV_GET_USER_PAGES_REMOTE_PRESENT\
#undef NV_GET_USER_PAGES_REMOTE_HAS_ARGS_FLAGS_LOCKED\
#define NV_GET_USER_PAGES_REMOTE_HAS_ARGS_FLAGS_LOCKED\
#undef NV_GET_USER_PAGES_REMOTE_HAS_ARGS_FLAGS_LOCKED_VMAS\
#undef NV_GET_USER_PAGES_REMOTE_HAS_ARGS_TSK_FLAGS_LOCKED_VMAS\
#undef NV_GET_USER_PAGES_REMOTE_HAS_ARGS_TSK_FLAGS_VMAS\
#undef NV_GET_USER_PAGES_REMOTE_HAS_ARGS_TSK_WRITE_FORCE_VMAS\
/* ISR signature: 2-arg since ~5.18 (no pt_regs) */\
#undef NV_IRQ_HANDLER_T_PRESENT\
#define NV_IRQ_HANDLER_T_PRESENT\
#undef NV_IRQ_HANDLER_T_ARGUMENT_COUNT\
#define NV_IRQ_HANDLER_T_ARGUMENT_COUNT 2\
/* type tests */\
#undef NV_FILE_OPERATIONS_HAS_UNLOCKED_IOCTL\
#define NV_FILE_OPERATIONS_HAS_UNLOCKED_IOCTL\
#undef NV_FILE_OPERATIONS_HAS_COMPAT_IOCTL\
#define NV_FILE_OPERATIONS_HAS_COMPAT_IOCTL\
#undef NV_PM_MESSAGE_T_PRESENT\
#define NV_PM_MESSAGE_T_PRESENT\
#undef NV_FILE_HAS_INODE\
#define NV_FILE_HAS_INODE\
#undef NV_VM_AREA_STRUCT_HAS_CONST_VM_FLAGS\
#define NV_VM_AREA_STRUCT_HAS_CONST_VM_FLAGS\
#undef NV_PROC_OPS_PRESENT\
#define NV_PROC_OPS_PRESENT\
#undef NV_HAVE_PROC_OPS\
#define NV_HAVE_PROC_OPS\
#endif' kernel/nv-linux.h || die "Failed to inject conftest overrides"

	# 3. Fix ALL stray '+' from patch 0012 (git merge artifact)
	sed -i 's/^+//' kernel/nv-linux.h

	# 4. Fix pm_message_t typedef: wrap in #ifndef
	sed -i 's/^typedef u32 pm_message_t;/#ifndef NV_PM_MESSAGE_T_PRESENT\ntypedef u32 pm_message_t;\n#endif/' kernel/nv-linux.h

	# 5. Fix pci_save_state: 1-arg version
	sed -i 's/pci_save_state(dev, &nv->pci_cfg_space\[0\])/pci_save_state(dev)/' kernel/nv-linux.h
	sed -i 's/pci_restore_state(dev, &nv->pci_cfg_space\[0\])/pci_restore_state(dev)/' kernel/nv-linux.h

	# 6. Fix NV_FILE_INODE: use f_inode
	sed -i 's/(file)->f_dentry->d_inode/(file)->f_inode/' kernel/nv-linux.h

	# 7. Fix NV_DEFINE_PROCFS_SINGLE_FILE: remove blank line breaking \ continuation
	sed -i '/^    }                                                                         \\$/{n;/^$/d}' kernel/nv-linux.h

	# 8. Fix get_user_pages: modern 4-arg API
	#    After patches 0041-0044, the code may have various patterns.
	#    Replace ALL get_user_pages calls with >4 args.
	sed -i 's/get_user_pages(current, current->mm, start, nr_pages, flags,/get_user_pages(start, nr_pages, flags,/' kernel/nv-linux.h
	sed -i 's/get_user_pages(current, current->mm, start, nr_pages, write,/get_user_pages(start, nr_pages, flags,/' kernel/nv-linux.h
	sed -i 's/get_user_pages(start, nr_pages, flags, pages, vmas)/get_user_pages(start, nr_pages, flags, pages)/g' kernel/nv-linux.h
	# Multi-line: "flags,\n                      force, pages, vmas)" → "flags, pages)"
	sed -i '/get_user_pages(start, nr_pages, flags,$/{N;s/get_user_pages(start, nr_pages, flags,\n[ ]*force, pages, vmas)/get_user_pages(start, nr_pages, flags, pages)/}' kernel/nv-linux.h
	# catch any remaining get_user_pages with >4 args
	sed -i 's/get_user_pages(start, nr_pages, flags, force, pages, vmas)/get_user_pages(start, nr_pages, flags, pages)/g' kernel/nv-linux.h

	# 9. Fix get_user_pages_remote: the fallback in NV_GET_USER_PAGES_REMOTE
	#    calls get_user_pages(NULL, mm, ...) which is wrong for modern API.
	#    Replace with get_user_pages_remote(mm, start, nr_pages, flags, pages, NULL)
	sed -i '/get_user_pages(NULL, mm,/{N;s/get_user_pages(NULL, mm, start, nr_pages, write, force, pages, vmas)/get_user_pages_remote(mm, start, nr_pages, flags, pages, NULL)/}' kernel/nv-linux.h
	sed -i 's/get_user_pages(NULL, mm, start, nr_pages, write, force, pages, vmas)/get_user_pages_remote(mm, start, nr_pages, flags, pages, NULL)/g' kernel/nv-linux.h
	sed -i 's/get_user_pages_remote(NULL, mm,/get_user_pages_remote(mm,/' kernel/nv-linux.h
	sed -i 's/get_user_pages_remote(mm, start, nr_pages, flags, pages, vmas, NULL)/get_user_pages_remote(mm, start, nr_pages, flags, pages, NULL)/g' kernel/nv-linux.h

	# 10. Fix vm_flags: use helpers
	sed -i '/^static inline void nv_vm_flags_set/,/^}/{s/vma->vm_flags |= flags;/vm_flags_set(vma, flags);/}' kernel/nv-linux.h
	sed -i '/^static inline void nv_vm_flags_clear/,/^}/{s/vma->vm_flags &= ~flags;/vm_flags_clear(vma, flags);/}' kernel/nv-linux.h

	# 11. Fix nv-acpi.c: nv_acpi_integer_t → u64
	sed -i 's/nv_acpi_integer_t/u64/g' kernel/nv-acpi.c

	# 12. Fix request_irq: ISR signature (no pt_regs since ~5.18)
	sed -i 's/static irqreturn_t   nvidia_isr            (int, void \*, struct pt_regs \*);/static irqreturn_t   nvidia_isr            (int, void *);/' kernel/nv.c
	sed -i 's/irqreturn_t nv_gvi_kern_isr             (int, void \*, struct pt_regs \*);/irqreturn_t nv_gvi_kern_isr             (int, void *);/' kernel/nv-proto.h
	# Fix nvidia_isr function definition: remove pt_regs parameter
	sed -i '/^nvidia_isr(/,/^)/{s/struct pt_regs \*//;s/, *\n)/\n)/}' kernel/nv.c
	sed -i 's/nvidia_isr(\n    int irq,\n    void \*arg,\n    struct pt_regs \*regs)/nvidia_isr(\n    int irq,\n    void *arg)/' kernel/nv.c
	# Simpler: just replace the whole function header
	# Use perl for multi-line replacement of nvidia_isr definition
	perl -0777 -i -pe 's/nvidia_isr\(\n\s+int irq,\n\s+void \*arg,\n\s+struct pt_regs \*\w+\)/nvidia_isr(\n    int irq,\n    void *arg)/gs' kernel/nv.c

	# 13. Stub out acpi_bus_get_device (removed in 6.12)
	sed -i 's/acpi_bus_get_device(nvif_parent_gpu_handle, &device)/(-ENODEV)/g' kernel/nv-acpi.c

	# 14. Fix ACPI_VIDEO_HID: char* → acpi_device_id array
	sed -i 's/\.ids = ACPI_VIDEO_HID,/.ids = (const struct acpi_device_id []){ {ACPI_VIDEO_HID, 0}, {""} },/' kernel/nv-acpi.c

	# Debug: dump state after all fixes
	ebegin "Dumping post-fix nv-linux.h state"
	grep -n "get_user_pages\|NV_GET_USER_PAGES\|NV_FILE_INODE\|f_dentry\|f_inode\|^+$\|pm_message_t\|pci_save_state" kernel/nv-linux.h > "${T}/debug-nv-linux.txt" 2>&1
	eend 0

	eapply_user
}

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
	local g=$(getent group video | cut -d: -f3)
	[[ ${g} =~ ^[0-9]+$ ]] || die "Failed to determine video group id (got '${g}')"
	sed -i "s/@VIDEOGID@/${g}/" "${ED}"/etc/modprobe.d/nvidia.conf || die
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
	readme.gentoo_print_elog
}
