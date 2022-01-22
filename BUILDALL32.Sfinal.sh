#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}


cd utils

source ../0_append_distro_path_32.sh
cd ..

sh utils/INSTALL.sh ${STAGE1} ${STAGE1}/output

sh utils/PACKDIR.sh ${STAGE1}/output ${X_SRCDIR}/${PROJ}-${X_TARGET}-${X_THREAD}-${_default_msvcrt}-${REV}

rm -rf ${STAGE1}/output