#!/bin/bash

if [ $# -gt 0 ]; then
    BRANCH=$1
else
    BRANCH=develop
fi

TOPDIR=`pwd`

AWK=awk
MD5SUM=md5sum

GIT_LINK="github.com:xianyi/OpenBLAS.git"

OS_list=(Win32 Win64-int32 Win64-int64)
COMMAND_list[0]="BINARY=32 CC=i686-w64-mingw32-gcc FC=i686-w64-mingw32-gfortran"
COMMAND_list[1]="BINARY=64 CC=x86_64-w64-mingw32-gcc FC=x86_64-w64-mingw32-gfortran"
COMMAND_list[2]="BINARY=64 CC=x86_64-w64-mingw32-gcc FC=x86_64-w64-mingw32-gfortran INTERFACE64=1"

N=${#OS_list[@]}

for (( i=0; i<$N; i++));  do
    echo ${OS_list[$i]}
    echo ${BRANCH}-${OS_list[$i]} Start  at `date`

    rm -rf ${OS_list[$i]}
    mkdir -p ${OS_list[$i]}
    cd ${OS_list[$i]}
    git clone $GIT_LINK .
    git checkout $BRANCH

#build
    echo "make QUIET_MAKE=1 TARGET=NEHALEM DYNAMIC_ARCH=1 HOSTCC=gcc NUM_THREADS=64 ${COMMAND_list[$i]}" > build.log
    make QUIET_MAKE=1 TARGET=NEHALEM DYNAMIC_ARCH=1 HOSTCC=gcc NUM_THREADS=64 ${COMMAND_list[$i]} >> build.log
    make TARGET=NEHALEM DYNAMIC_ARCH=1 HOSTCC=gcc NUM_THREADS=64 ${COMMAND_list[$i]} PREFIX=$TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]} install
   # cp exports/libopenblas.def $TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]}/lib
    cp build.log $TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]}/readme.txt
    cd -

#mv libopenblas_xxx.a libopenblas.a
    cd $TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]}/lib
    cp libopenblas.a libopenblas.a_1
    mv libopenblas.dll.a libopenblas.dll.a_1
    rm -f *.a
    mv libopenblas.a_1 libopenblas.a
    mv libopenblas.dll.a_1 libopenblas.dll.a
    cd -

#check md5, copy libopenblas import export library.
    # af68bc634292ca0c735c0d8f08d76d68
#    LIBOPENBLAS_DEF_MD5=`${MD5SUM} $TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]}/lib/libopenblas.def | ${AWK} '{print $1}'`
#    cp ./data/${LIBOPENBLAS_DEF_MD5}/${OS_list[$i]}/libopenblas.* OpenBLAS-${BRANCH}-${OS_list[$i]}/lib/

    cat ./data/template.txt >> $TOPDIR/OpenBLAS-${BRANCH}-${OS_list[$i]}/readme.txt
#package
    zip -r OpenBLAS-${BRANCH}-${OS_list[$i]}.zip OpenBLAS-${BRANCH}-${OS_list[$i]}/

    echo ${BRANCH}-${OS_list[$i]} End  at `date`

done
