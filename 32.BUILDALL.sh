#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}

build_toolchain()
{
	cd ${DIR}

	sh BUILDALL32.S1.sh && sh BUILDALL32.Sfinal.sh && echo "===================== Success ====================="
}


build_toolchain

