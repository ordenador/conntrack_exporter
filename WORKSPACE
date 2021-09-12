
load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
http_archive(
    name = "com_github_jupp0r_prometheus_cpp",
    strip_prefix = "prometheus-cpp-master",
    urls = ["https://github.com/jupp0r/prometheus-cpp/archive/master.zip"],
)

load("@com_github_jupp0r_prometheus_cpp//bazel:repositories.bzl", "prometheus_cpp_repositories")
prometheus_cpp_repositories()


new_local_repository(
    name = "libnetfilter_conntrack",
    path = "/usr/include",
    build_file_content = """
cc_library(
    name = "libnetfilter_conntrack",
    includes = ["."],
    visibility = ["//visibility:public"],
)
"""
)


new_git_repository(
    name = "argagg",
    remote = "https://github.com/vietjtnguyen/argagg.git",
    tag = "0.4.6",
    build_file_content = """
cc_library(
    name = "argagg",
    hdrs = ["include/argagg/argagg.hpp"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
"""
)
