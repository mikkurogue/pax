const std = @import("std");
const ZonParser = @import("../lib/lib.zig").parser.ZonParser;

pub const DefaultProject = struct { name: []const u8, version: []const u8, dependencies: []Dependency, paths: [][]const u8 };

pub const Dependency = struct {
    url: []const u8,
    path: []const u8,
    hash: []const u8,
    lazy: bool,
};

/// Initialise a new zig project in the current folder.
pub fn init_project() !void {}

/// Scaffold the project - essentially make sure we have the project config file
/// too for the dependencies ready
pub fn scaffold(project_name: []const u8) !void {
    const default = DefaultProject{ .name = project_name, .version = "0.0.0", .paths = &[_][]const u8{}, .dependencies = &[_]Dependency{} };

    try ZonParser.marshal_dynamic(DefaultProject, default, "1build.zig.zon");
}

test "test scaffold" {
    try scaffold("Test");
}
