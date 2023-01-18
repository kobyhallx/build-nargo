#!/usr/bin/env bash


NOIR_DIR="noir"
AZTEC_BACKEND_DIR="aztec_backend"
AZTEC_CONNECT_DIR="aztec-connect"
GIT_VENDOR_URL="https://github.com"
NOIR_REPO_PATH="noir-lang/noir"
AZTEC_BACKEND_REPO_PATH="noir-lang/aztec_backend"
AZTEC_CONNECT_REPO_PATH="noir-lang/aztec-connect"
main_dir=$(pwd)


if [[ -d "$NOIR_DIR" ]]; then
    echo "$NOIR_DIR exists on your filesystem, using it for build..."
else
    echo "$NOIR_DIR does not exists on your filesystem, clonning from $NOIR_CLONE_URL"
    git clone $GIT_VENDOR_URL/$NOIR_REPO_PATH $NOIR_DIR
    cd $main_dir/$NOIR_DIR
    # git checkout 
fi

AZTEC_BACKEND_REV=$(toml2json $main_dir/noir/crates/nargo/Cargo.toml | jq -r .dependencies.aztec_backend.rev)

if [[ -d "$AZTEC_BACKEND_DIR" ]]; then
    echo "$AZTEC_BACKEND_DIR exists on your filesystem, using it for build..."
else
    echo "$AZTEC_BACKEND_DIR does not exists on your filesystem, clonning from $NOIR_CLONE_URL"
    git clone $GIT_VENDOR_URL/$AZTEC_BACKEND_REPO_PATH $AZTEC_BACKEND_DIR
    echo "Checkout $AZTEC_BACKEND_REV rev."
    cd $main_dir/$AZTEC_BACKEND_DIR
    git checkout $AZTEC_BACKEND_REV
fi

AZTEC_CONNECT_REV=$(toml2json aztec_backend/barretenberg_static_lib/Cargo.toml | jq -r .dependencies.barretenberg_wrapper.rev)

if [[ -d "$AZTEC_CONNECT_DIR" ]]; then
    echo "$AZTEC_CONNECT_DIR exists on your filesystem, using it for build..."
else
    echo "$AZTEC_CONNECT_DIR does not exists on your filesystem, clonning from $NOIR_CLONE_URL"
    git clone $GIT_VENDOR_URL/$AZTEC_CONNECT_REPO_PATH $AZTEC_CONNECT_DIR
    echo "Checkout $AZTEC_CONNECT_REV rev."
    cd $main_dir/$AZTEC_CONNECT_DIR
    git checkout $AZTEC_CONNECT_REV
fi

cd $main_dir/$NOIR_DIR
git apply $main_dir/noir.patch

cd $main_dir/$AZTEC_BACKEND_DIR
git apply $main_dir/aztec_backend.patch

cd $main_dir/$AZTEC_CONNECT_DIR
git apply $main_dir/aztec-connect.patch

cd $main_dir/$AZTEC_CONNECT_DIR/barretenberg

cd $main_dir/noir/crates/nargo
cargo clean
cargo build --release --target $TARGET_PLATFORM_CONFIG
# ./bootstrap.sh