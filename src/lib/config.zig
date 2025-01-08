const std = @import("std");
const fs = std.fs;
const Tuple = std.meta.Tuple;
const StrEql = std.mem.eql;
const Allocator = std.mem.Allocator;

pub const ConfigError = error{ ConfigurataionAlreadyExists, CanNotRead, CanNotWrite, CanNotCreatePackagesDir };
const install_dir = "~/.config/zigpkg/packages";
const cache_dir = "~/.config/zigpkg/cache";

const config_file_path = &[_][]const u8{
    "~",
    ".config",
    "zigpkg",
    "config.zig.zon",
};
const config_dir_path = &[_][]const u8{
    "~",
    ".config",
    "zigpkg",
};

// this is probably not necessary
pub const Config = struct {
    install_dir: []const u8,
    cache_dir: []const u8,

    pub fn default() Config {
        return Config{
            .install_dir = "~/.config/zigpkg/packages",
            .cache_dir = "~/.config/zigpkg/cache",
        };
    }

    pub fn toZon(self: *const Config, allocator: std.mem.Allocator) ![]const u8 {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        try buffer.appendSlice(".{\n");
        try buffer.appendSlice("install_dir = \"");
        try buffer.appendSlice(self.install_dir);
        try buffer.appendSlice("\",\n");
        try buffer.appendSlice("cache_dir = \"");
        try buffer.appendSlice(self.cache_dir);
        try buffer.appendSlice("}\n");

        return buffer.toOwnedSlice();
    }
};

/// FIXME: Need to somehow fix the concatenating of the strings for the directories here.
/// Create an initial config in ~/.config/zigpkg/config.zig.zon
///
/// FIXME: Fix the buffer writer thing cause it doesnt work and im actually brainless
pub fn create_initial_config() ConfigError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const config_dir = try fs.path.join(allocator, config_dir_path);
    const config_file = try fs.path.join(allocator, config_file_path);

    var dir = try fs.cwd().openDir(".", .{});
    const dir_stat = dir.stat(config_dir);

    if (dir_stat catch error.PathNotFound) {
        try dir.makeDir(config_dir_path, 0o755);
    } else if (dir_stat catch |e| e != error.None) {
        return ConfigError.CanNotCreatePackagesDir;
    }

    var cfg_file = try fs.cwd().createFile(config_file, .{});
    defer cfg_file.close();

    const config_zon = try Config.toZon(allocator);
    defer allocator.free(config_zon);

    try config_file.write(config_zon);
}

/// Write to the config in ~/.config/zigpkg/config.zig.zon
/// This should be like writing a newly installed package
/// or removing a package
/// (upgrade package probably at a later point)
pub fn write_to_config(package: []const u8, action: []const u8) ConfigError!void {
    _ = package;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const config_file = try fs.path.join(allocator, config_file_path);
    defer allocator.free(config_file);

    const file = try fs.cwd().openFile(config_file, .{});
    defer file.close();

    var buffer: [4096]u8 = undefined;
    const content = try file.readAll(&buffer);
    _ = content;

    var config = Config.default();
    // parse the content into config, replacing whatever may be needed to be replaced.

    if (StrEql(u8, action, "install")) {
        // Make sure the package doesnt exist already
        // IMPL TODO
    } else if (StrEql(u8, action, "remove")) {
        // Remove the package, if it exists in the config
        // IMPL TODO
    } else if (StrEql(u8, action, "upgrade")) {
        // Make sure the package exists
        // IMPL TODO
    }

    const updated_zon = try config.toZon(allocator);
    defer allocator.free(updated_zon);

    const write_file = try fs.cwd().createFile(config_file, .{});
    defer write_file.close();

    try write_file.write(updated_zon);
}

/// Read from the config to be able to find an installed package on the system
/// this has nothing to do with the registry yet
pub fn read_from_config(package: []const u8) ConfigError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const config_file = try fs.path.join(allocator, config_file_path);
    defer allocator.free(config_file);

    const file = try fs.cwd().openFile(config_file, .{});
    defer file.close();

    var buffer: [4096]u8 = undefined;
    const content = try file.readAll(&buffer);

    _ = content;
    _ = package;

    // TODO: parse the file content and find the package given in the props
}
