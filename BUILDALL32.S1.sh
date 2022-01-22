#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}

cd utils

source ../0_append_distro_path_32.sh
source ../BUILD_COMMON.sh
cd ..


rm -rf ${STAGE1}
mkdir -p ${STAGE1}

buildpkg S1.0001.binutils 32.binutils.sh ${STAGE1}

buildpkg S1.0002.gcc 32.gcc.sh ${STAGE1}

