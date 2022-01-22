#!/bin/sh


DIR=$(dirname $0)

for i in $(find ${DIR}/../ -name "*.tar.*")
do
rm -f ${i}
done
