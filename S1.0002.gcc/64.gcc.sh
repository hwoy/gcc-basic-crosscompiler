#!/bin/sh
source ../0_append_distro_path.sh

SNAME=gcc
SVERSION=11.2.0


# Extract vanilla sources.

decompress()
{
	untar_file gmp-6.2.1.tar.xz
	untar_file mpfr-4.1.0.tar.xz
	untar_file mpc-1.2.1.tar.gz
	untar_file isl-0.24.tar.xz

	untar_file ${SNAME}-${SVERSION}.tar.xz
}

prepare()
{
	cd patch
	patch -Z -d ${X_BUILDDIR}/mpfr-4.1.0 -p1 < mpfr-4.1.0-p13.patch
	cd ..
}

build()
{
	#No use libiconv
	#export am_cv_func_iconv=no
	export lt_cv_deplibs_check_method='pass_all'
	#export gcc_cv_libc_provides_ssp=yes

	cd ${X_BUILDDIR}

	# Prepare to build gcc.
	mv ${SNAME}-${SVERSION} src
	mv gmp-6.2.1 src/gmp
	mv mpfr-4.1.0 src/mpfr
	mv mpc-1.2.1 src/mpc
	mv isl-0.24 src/isl

	# Configure.
	GCC_PARAMS=" "
	ZST=${X_BUILDDIR}/zstd-1.5.1
	ICONV=${X_BUILDDIR}/libiconv-1.16
	_arch=x86-64
	local _LDFLAGS_FOR_TARGET="$LDFLAGS"

	_config=""
	_config="${_config} --with-gnu-as --with-gnu-ld"
	#_config="${_config} --disable-tm-clone-registry"
	#_config="${_config} --disable-tls"
	#_config="${_config} --disable-libffi"
	#_config="${_config} --disable-decimal-float"
	#_config="${_config} --enable-gnu-indirect_function"
	#_config="${_config} --with-libelf"
	#_config="${_config} --enable-gnu-indirect_function"
	#_config="${_config} --with-multilib-list=rmprofile"

	mkdir build
	cd build

	../src/configure --enable-languages=c,c++ \
		--build=${X_BUILD} --host=${X_HOST} --target=${X_TARGET} \
		--prefix=${X_BUILDDIR}/dest \
		--disable-win32-registry \
		--disable-bootstrap \
		--with-sysroot=${NEW_DISTRO_ROOT}                            \
		--with-newlib                                  \
		--without-headers                              \
		--enable-initfini-array                        \
		--disable-nls                                  \
		--disable-shared                               \
		--disable-multilib                             \
		--disable-decimal-float                        \
		--disable-threads                              \
		--disable-libatomic                            \
		--disable-libgomp                              \
		--disable-libquadmath                          \
		--disable-libssp                               \
		--disable-libvtv                               \
		--disable-libstdcxx                            \
		--with-pkgversion="${PROJECTNAME} ${REV}, Built by ${AUTHOR}" \
		${_config} \
		${GCC_PARAMS}



	# --enable-languages=c,c++        : I want C and C++ only.
	# --build=${X_BUILD}      : I want a native compiler.
	# --host=${X_HOST}       : Ditto.
	# --target=${X_TARGET}     : Ditto.
	# --disable-multilib              : I want 64-bit only.
	# --prefix=${X_BUILDDIR}/dest       : I want the compiler to be installed here.
	# --with-sysroot=${X_BUILDDIR}/dest : Ditto. (This one is important!)
	# --disable-libstdcxx-pch         : I don't use this, and it takes up a ton of space.
	# --disable-libstdcxx-verbose     : Reduce generated executable size. This doesn't affect the ABI.
	# --disable-nls                   : I don't want Native Language Support.
	# --disable-shared                : I don't want DLLs.
	# --disable-win32-registry        : I don't want this abomination.
	# --enable-threads=posix          : Use winpthreads.
	# --enable-libgomp                : Enable OpenMP.
	# --with-zstd=$X_DISTRO_ROOT      : zstd is needed for LTO bytecode compression.
	# --disable-bootstrap             : Significantly accelerate the build, and work around bootstrap comparison failures.

	# Build and install.
	make $X_MAKE_JOBS V=1 all
	make install

	# Cleanup.
	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}

	#rm -rf usr
	#cp libgcc_s

	find -name "*.la" -type f -print -exec rm {} ";"
	find -name "*.exe" -type f -print -exec strip -s {} ";"

	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}


decompress

prepare

build
