cc_library(
    name = "keccak_tiny",
    srcs = [
        "define-macros.h",
        "keccak-tiny.c",
    ],
    hdrs = ["keccak-tiny.h"],
    copts = ["-O3"] + select({
        "@//:lto": ['-flto'],
        "@//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }),
    linkopts = select({
        "@//:lto": ['-flto'],
        "@//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }),
    includes = ["."],
    local_defines = select({
        # TODO: confirm which platforms have memset_s().
        "@platforms//os:linux": ["memset_s(W,WL,V,OL)=memset(W,V,OL)"],
        "//conditions:default": [],
    }),
    visibility = ["//visibility:public"],
)
