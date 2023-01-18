{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a83ed85c14fcf242653df6f4b0974b7e1c73c6c6.tar.gz") {} 
, target ? "x86_64-apple-darwin"
}:

let
  toolchain = "1.65.0";
  # target = "x86_64-apple-darwin";
  lib = pkgs.lib;
  # stdenv = pkgs.stdenv;
  stdenv = pkgs.llvmPackages_11.stdenv;
  libSystem = pkgs.darwin.apple_sdk_11_0.Libsystem;
  inherit (pkgs.darwin.apple_sdk_11_0.frameworks) AppKit CoreFoundation IOKit Security System;
  # System = null;
  MacOSX-SDK = pkgs.darwin.apple_sdk_11_0.MacOSX-SDK or null;
in
pkgs.mkShell.override {stdenv = stdenv;} {

  nativeBuildInputs = with pkgs; [ 
    curl
    which
    cacert
    git
    pkg-config
    cmake
    # llvmPackages.llvm
    # llvmPackages.clang
    gtest
    rocksdb
    glibc
    rustup
    cargo
    rustc
  ];
  
  buildInputs = with pkgs; [ 
    # llvmPackages.llvm
    llvmPackages.libclang
    llvmPackages.openmp
    openssl
    libiconv
    zlib
  ] ++ lib.optionals stdenv.isLinux [
    # udev
  ] ++ lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [

  ]
  ++ lib.optionals stdenv.isDarwin [
    # libSystem
    # AppKit
    # CoreFoundation
    # IOKit
    Security
    # System
  ];

  # clang -Xlinker -v
  # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    # pkgs.llvmPackages.llvm
    # libSystem
    # pkgs.llvmPackages.libclang
    # pkgs.llvmPackages.openmp
    # pkgs.openssl
    # pkgs.libiconv
  # ];
  # DYLD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    # pkgs.llvmPackages.llvm
    # libSystem
    # pkgs.llvmPackages.libclang
    # pkgs.llvmPackages.openmp
    # pkgs.openssl
    # pkgs.libiconv
  # ];

  # src = pkgs.fetchFromGitHub {
  #   owner = "noir-lang";
  #   repo = "noir";
  #   rev = "555314a6d3f993306ac740c24c27197b202ce2f3";
  #   sha256 = "sha256-MMSb6KJK5GPGOnxKLbeH8cIz7L9QjVLFp0k40JoFQJY=";
  # };

  # LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  # LLVM_CONFIG_PATH = "${pkgs.llvmPackages.llvm}/bin/llvm-config";
  OPENSSL_NO_VENDOR = 1; # we want to link to OpenSSL provided by Nix

  # NIX_LDFLAGS = if (!stdenv.isDarwin || MacOSX-SDK == null) then null else [
  #   # XXX: as System framework is broken, use MacOSX-SDK directly instead
  #   "-F${MacOSX-SDK}/System/Library/Frameworks"
  # ];

  BREW_PREFIX = "${pkgs.llvmPackages.openmp}";
  NIX_CFLAGS_COMPILE = ["-fno-aligned-allocation"];
  CMAKE_CXX_COMPILER = "${pkgs.llvmPackages.llvm}/bin/clang++";
  CMAKE_C_COMPILER = "${pkgs.llvmPackages.llvm}/bin/clang";

  shellHook = ''
    # export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
    #   $(< ${stdenv.cc}/nix-support/libc-cflags) \
    #   $(< ${stdenv.cc}/nix-support/cc-cflags) \
    #   $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
    #   ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
    #   ${lib.optionalString stdenv.cc.isGNU "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include"} \
    # "
    echo 🧪 SDK=${MacOSX-SDK.name}
    echo 🧪 src=$src
    echo 🧪 NIX_CFLAGS_COMPILE=$NIX_CFLAGS_COMPILE
    echo 🧪 NIX_LDFLAGS=$NIX_LDFLAGS
    echo 🧪 LD_LIBRARY_PATH=$LD_LIBRARY_PATH
    echo 🧪 CPATH=$CPATH
    echo 🧪 $CC $AR $CXX $LD
    echo 🧪 $(which $CC) 
    echo 🧪 $(which $AR) 
    echo 🧪 $(which $CXX) 
    echo 🧪 $(which $LD)
    echo 🧪 $(which pkg-config)
    echo 🧪 pkg-config --list-all ↩️
    pkg-config --list-all
    echo ⌛
    # mkdir -p /usr/local/opt/llvm/bin/
    # ln -s $(which $CC) /usr/local/opt/llvm/bin/clang
    # ln -s $(which $CXX) /usr/local/opt/llvm/bin/clang++
    echo 🧪 $CC -v ↩️
    $CC -v
    echo ⌛
    echo 🧪 $CXX -v ↩️
    $CXX -v
    echo ⌛
    rustup toolchain install ${toolchain} --target ${target}
    rustup default ${toolchain}-${target}
    echo 🧪 $(which cargo)
    echo 🧪 cargo --version = $(cargo --version)
    BUILD_TOP=nargo-build
    # mkdir $BUILD_TOP
    # echo 🧪 Copy source from $src to $BUILD_TOP
    # cp -R $src/* $BUILD_TOP/
    # echo $BUILD_TOP
    # cd $BUILD_TOP
    
  '';

}
