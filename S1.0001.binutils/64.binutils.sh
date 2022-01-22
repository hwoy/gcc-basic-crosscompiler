#!/bin/sh
# https://sourceware.org/git/?p=binutils-gdb.git;a=commit;h=999566402e3d7c69032bbf47e28b44fc0926fe62

source ../0_append_distro_path.sh

SNAME=binutils
SVERSION=2.37

decompress()
{
	untar_file ${SNAME}-${SVERSION}.tar.xz
}

prepare()
{
	cd patch

	apply_patch_p1 \
		0002-check-for-unusual-file-harder.patch \
		0010-bfd-Increase-_bfd_coff_max_nscns-to-65279.patch \
		0110-binutils-mingw-gnu-print.patch \
		0600-Change-uint-to-unsigned.patch
			# Add an option to change default bases back below 4GB to ease transition
			# https://github.com/msys2/MINGW-packages/issues/7027
			# https://github.com/msys2/MINGW-packages/issues/7023
			apply_patch_p1 2001-ld-option-to-move-default-bases-under-4GB.patch
			# https://github.com/msys2/MINGW-packages/pull/9233#issuecomment-889439433
			apply_reverse_patch_p1 "2003-Restore-old-behaviour-of-windres-so-that-options-con.patch"

	# patches for reproducibility from Debian:
	# https://salsa.debian.org/mingw-w64-team/binutils-mingw-w64/-/tree/master/debian/patches
	apply_patch_p2 "reproducible-import-libraries.patch"
	apply_patch_p2 "specify-timestamp.patch"

	# https://sourceware.org/bugzilla/show_bug.cgi?id=28138
	apply_patch_p1 2004-bfd-Close-the-file-descriptor-if-there-is-no-archive.patch

	cd ..
}

build()
{
	cd ${X_BUILDDIR}
	mv ${SNAME}-${SVERSION} src
	mkdir build dest
	cd build

	BINUTILS_PARAM=" --enable-64-bit-bfd"

	../src/configure \
		--build=${X_BUILD} \
		--host=${X_HOST} \
		--target=${X_TARGET} \
		--prefix=${X_BUILDDIR}/dest \
		--disable-multilib \
		--disable-shared \
		--enable-lto \
		--disable-werror \
		--disable-nls \
		--disable-rpath \
		${BINUTILS_PARAM}

	make $X_MAKE_JOBS all
	make  install

	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	rm -rf lib/*.la share
	# https://github.com/msys2/MINGW-packages/issues/7890
	rm -rf lib/bfd-plugins/libdep.a

	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z
}

decompress

prepare

build

