cc_library(
    name = "sse2neon",
    hdrs = ["sse2neon.h"],
    copts = ["-O3"] + select({
        "@//:lto": ['-flto'],
        "@//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }),
    linkstatic = True,
    visibility = ["//visibility:public"],
)
