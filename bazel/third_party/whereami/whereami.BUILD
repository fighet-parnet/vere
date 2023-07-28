cc_library(
    name = "whereami",
    srcs = ["src/whereami.c"],
    hdrs = ["src/whereami.h"],
    copts = ["-O3"] + select({
        "@//:lto": ['-flto'],
        "@//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }),
    includes = ["src"],
    visibility = ["//visibility:public"],
)
