#!/usr/bin/env fish

set fish_trace 1

set nonce $(random)
set dir /tmp/urbit-vere-pgo-$nonce

mkdir $dir

set -gx BAZEL_FDO_DIR $dir

bazel build -s :urbit --per_file_copt="pkg/.*@-fprofile-generate=$BAZEL_FDO_DIR" --linkopt="-fprofile-generate=$BAZEL_FDO_DIR"

