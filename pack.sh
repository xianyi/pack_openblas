#!/bin/bash

if [ $# -gt 0 ]; then
    BRANCH=$1
else
    BRANCH=develop
fi

TOPDIR=`pwd`

GIT_LINK="github.com:xianyi/OpenBLAS.git"

OS_list=(x86-Win x86_64-Win)
COMMAND_list[0]="BINARY=32 CC=i686-w64-mingw32-gcc FC=i686-w64-mingw32-gfortran"
COMMAND_list[1]="BINARY=64 CC=x86_64-w64-mingw32-gcc FC=x86_64-w64-mingw32-gfortran"

N=${#OS_list[@]}

for (( i=0; i<$N; i++));  do
    echo ${OS_list[$i]}
    rm -rf ${OS_list[$i]}
    mkdir -p ${OS_list[$i]}
    cd ${OS_list[$i]}
    git clone $GIT_LINK .
    git checkout $BRANCH
    make TARGET=NEHALEM DYNAMIC_ARCH=1 HOSTCC=gcc NUM_THREADS=64 ${COMMAND_list[$i]}
    make TARGET=NEHALEM DYNAMIC_ARCH=1 HOSTCC=gcc NUM_THREADS=64 ${COMMAND_list[$i]} PREFIX=$TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]} install
    cd ..
    cd $TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]}/lib
    cp libopenblas.a libopenblas.a_1
    rm -f *.a
    mv libopenblas.a_1 libopenblas.a
    cd -
done
