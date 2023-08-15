# For more, see https://bazel.build/extending/config and
# https://github.com/bazelbuild/bazel-skylib/blob/main/rules/common_settings.bzl.
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def _impl(ctx):
    return BuildSettingInfo(value = ctx.build_setting_value)

string_flag = rule(
    implementation = _impl,
    build_setting = config.string(flag = True),
    doc = "A string-typed build setting that can be set on the command line",
)

envvars_read = dict()

def _capture_impl(ctx):
    print("adding " + ctx.attrs.envvar + " to dictionary")
    envvars_read[ctx.attrs.envvar] = ctx.configuration.default_shell_env[ctx.attrs.envvar]
    value = ctx.build_setting_value
    return BuildSettingInfo(value = value)

bool_flag_with_envvar = rule(
    implementation = _capture_impl,
    build_setting = config.bool(flag = True),
    attrs = {
        "envvar": attr.string(
            doc = "The environment variable name which will be saved for use by vere_{binary,library} at build time.",
        ),
    },
    doc = "A bool type flag which captures an environment variable for use by vere_library",
)

# def _define_from_flag_impl(ctx):
#     return CcInfo(
#         compilation_context = cc_common.create_compilation_context(
#             defines = depset([
#                 "FLAG=\"{}\"".format(
#                     ctx.attr.value[BuildSettingInfo].value,
#                 ),
#             ]),
#         ),
#     )
# define_from_flag = rule(
#     implementation = _define_from_flag_impl,
#     attrs = {
#         "value": attr.label(),
#     },
# )

 # + select({
 #        "//:build_instrumentation": ["-fprofile-generate=" + envvars_read["VERE_INSTRUMENTATION_DIR"]],
 #        "//conditions:default": [],
 #    })


def vere_library(copts = [], linkopts = [], **kwargs):
  native.cc_library(
    copts = copts + select({
        "//:debug": ["-O0", "-g3", "-DC3DBG"],
        "//conditions:default": ["-O3"]
    }) + select({
        "//:lto": ['-flto'],
        "//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }) + select({
        # Don't include source level debug info on macOS. See
        # https://github.com/urbit/urbit/issues/5561 and
        # https://github.com/urbit/vere/issues/131.
        "//:debug": [],
        "@platforms//os:linux": ["-g"],
        "//conditions:default": [],
    }),
    linkopts = linkopts + ['-g'] + select({
        "//:lto": ['-flto'],
        "//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }),
    **kwargs,
  )

def vere_binary(copts = [], linkopts = [], **kwargs):
  native.cc_binary(
    copts = copts + select({
        "//:debug": ["-O0", "-g3", "-DC3DBG"],
        "//conditions:default": ["-O3"]
    }) + select({
        "//:lto": ['-flto'],
        "//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }) + select({
        "//:debug": [],
        "@platforms//os:linux": ["-g"],
        "//conditions:default": [],
    }),
    linkopts = linkopts + ['-g'] + select({
        "//:lto": ['-flto'],
        "//:thinlto": ['-flto=thin'],
        "//conditions:default": []
    }),
    **kwargs,
  )
