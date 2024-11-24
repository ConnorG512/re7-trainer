const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {

    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "re7_trainer",
        .root_source_file = b.path("src/dll.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);
}
