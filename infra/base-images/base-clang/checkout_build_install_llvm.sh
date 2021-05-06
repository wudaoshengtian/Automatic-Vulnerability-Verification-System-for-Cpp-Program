#!/bin/bash -eux
# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# build clang & LLVM
LLVM_DEP_PACKAGES="build-essential make cmake ninja-build git subversion python2.7 binutils-gold binutils-dev curl wget"
apt-get install -y $LLVM_DEP_PACKAGES
mkdir $SRC/build; cd $SRC/build
mkdir llvm_tools; cd llvm_tools
wget http://releases.llvm.org/4.0.0/llvm-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/cfe-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/compiler-rt-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/libcxx-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/libcxxabi-4.0.0.src.tar.xz
tar xf llvm-4.0.0.src.tar.xz
tar xf cfe-4.0.0.src.tar.xz
tar xf compiler-rt-4.0.0.src.tar.xz
tar xf libcxx-4.0.0.src.tar.xz
tar xf libcxxabi-4.0.0.src.tar.xz
mv cfe-4.0.0.src $SRC/build/llvm_tools/llvm-4.0.0.src/tools/clang
mv compiler-rt-4.0.0.src $SRC/build/llvm_tools/llvm-4.0.0.src/projects/compiler-rt
mv libcxx-4.0.0.src $SRC/build/llvm_tools/llvm-4.0.0.src/projects/libcxx
mv libcxxabi-4.0.0.src $SRC/build/llvm_tools/llvm-4.0.0.src/projects/libcxxabi
mkdir -p build-llvm/llvm; cd build-llvm/llvm
cmake -G "Ninja" \
      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
      -DLLVM_BINUTILS_INCDIR=/usr/include $SRC/build/llvm_tools/llvm-4.0.0.src
ninja;  ninja install
cd $SRC/build/llvm_tools
mkdir -p build-llvm/msan; cd build-llvm/msan
cmake -G "Ninja" \
      -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
      -DLLVM_USE_SANITIZER=Memory -DCMAKE_INSTALL_PREFIX=/usr/msan/ \
      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
       $SRC/build/llvm_tools/llvm-4.0.0.src
ninja cxx; ninja install-cxx

# install LLVMgold in bfd-plugins
mkdir /usr/lib/bfd-plugins
cp /usr/local/lib/libLTO.so /usr/lib/bfd-plugins
cp /usr/local/lib/LLVMgold.so /usr/lib/bfd-plugins

cp $SRC/build/llvm_tools/llvm-4.0.0.src/tools/sancov/coverage-report-server.py /usr/local/bin/
