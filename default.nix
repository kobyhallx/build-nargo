{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/8c54d842d9544361aac5f5b212ba04e4089e8efe.tar.gz") {} 
, target ? pkgs.hostPlatform.config
, toolchain ? pkgs.rust.packages.stable.rustc.version
}:

let
  llvmPkgs = pkgs.llvmPackages_11;
  
  libSystem = pkgs.darwin.apple_sdk_11_0.Libsystem;
  inherit (pkgs.darwin.apple_sdk_11_0.frameworks) AppKit CoreFoundation IOKit Security System;
  # System = null;
  MacOSX-SDK = pkgs.darwin.apple_sdk_11_0.MacOSX-SDK or null;
in
pkgs.mkShell.override {stdenv = llvmPkgs.stdenv;} {

  nativeBuildInputs = with pkgs; [ 
    curl
    which
    cacert
    git
    jq
    toml2json
    # pkg-config
    # cmake
    gtest
    rocksdb
    rustup
    
  ] ++ lib.optionals stdenv.isLinux [ 
    # gcc
  ];
  
  buildInputs = with pkgs; [ 
    pkg-config
    cmake
    # glibc
    # gcc
  # llvmPackages.llvm
    llvmPackages.libclang
    llvmPackages.openmp
    # llvmPackages.libcxx
    openssl
  ] ++ lib.optionals stdenv.isLinux [
    # udev
  ] ++ lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [

  ]
  ++ lib.optionals stdenv.isDarwin [
    libiconv
    zlib
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

  LIBCLANG_PATH = "${pkgs.llvmPackages_11.libclang.lib}/lib";
  # LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  # LLVM_CONFIG_PATH = "${pkgs.llvmPackages.llvm}/bin/llvm-config";
  OPENSSL_NO_VENDOR = 1; # we want to link to OpenSSL provided by Nix

  TARGET_PLATFORM_CONFIG = target;
  # NIX_LDFLAGS = if (!stdenv.isDarwin || MacOSX-SDK == null) then null else [
  #   # XXX: as System framework is broken, use MacOSX-SDK directly instead
  #   "-F${MacOSX-SDK}/System/Library/Frameworks"
  # ];
  NIX_CFLAGS_COMPILE = if (pkgs.stdenv.isDarwin) then [" -fno-aligned-allocation"] else null;

  # BREW_PREFIX = "${pkgs.llvmPackages.openmp}";
  # CMAKE_CXX_COMPILER = "${pkgs.llvmPackages.llvm}/bin/clang++";
  # CMAKE_C_COMPILER = "${pkgs.llvmPackages.llvm}/bin/clang";

    # export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
    #   $(< ${stdenv.cc}/nix-support/libc-cflags) \
    #   $(< ${stdenv.cc}/nix-support/cc-cflags) \
    #   $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
    #   ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
    #   ${lib.optionalString stdenv.cc.isGNU "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include"} \
    # "
  shellHook = ''
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
    echo 🧪 TARGET_PLATFORM_CONFIG=$TARGET_PLATFORM_CONFIG
    echo 🧪 native build with: cargo build --release --target $TARGET_PLATFORM_CONFIG 
  '';
    # BUILD_TOP=nargo-build
    # mkdir $BUILD_TOP
    # echo 🧪 Copy source from $src to $BUILD_TOP
    # cp -R $src/* $BUILD_TOP/
    # echo $BUILD_TOP
    # cd $BUILD_TOP

}
