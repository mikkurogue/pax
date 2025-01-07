const std = @import("std");
const fs = std.fs;
const Tuple = std.meta.Tuple;
const StrEql = std.mem.eql;

pub const ConfigError = error{ ConfigurataionAlreadyExists, CanNotRead, CanNotWrite, CanNotCreatePackagesDir };

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
    const home_dir = std.posix.getenv("HOME") orelse unreachable;

    var fbuffer: [64]u8 = undefined;
    var dbuffer: [64]u8 = undefined;

    // Copy home_dir and the constant string into the buffer
    var config_file_buf = fbuffer.writer();
    try config_file_buf.writeAll(home_dir);
    try config_file_buf.writeAll(".config/zigpkg/config.zig.zon");

    var config_dir_buf = dbuffer.writer();
    try config_dir_buf.writeAll(home_dir);
    try config_dir_buf.writeAll("./config/zigpkg/");

    const config_dir_path = fs.path.join(std.heap.page_allocator, dbuffer[0..config_dir_buf.len]) catch return ConfigError.CanNotWrite;
    defer std.heap.page_allocator.free(config_dir_path);
    const config_file_path = try fs.path.join(std.heap.page_allocator, fbuffer[0..config_file_buf.len]);
    defer std.heap.page_allocator.free(config_file_path);

    var dir = try fs.cwd().openDir(".", .{});
    const dir_stat = dir.stat(config_dir_path);

    if (dir_stat catch error.PathNotFound) {
        try dir.makeDir(config_dir_path, 0o755);
    } else if (dir_stat catch |e| e != error.None) {
        return ConfigError.CanNotCreatePackagesDir;
    }

    const allocator = std.heap.page_allocator;
    var config_file = try fs.cwd().createFile(config_file_path, .{});
    defer config_file.close();

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
    const home_dir = std.posix.getenv("HOME") orelse unreachable;

    var fbuffer: [64]u8 = undefined;
    var dbuffer: [64]u8 = undefined;

    // Copy home_dir and the constant string into the buffer
    var config_file_buf = fbuffer.writer();
    try config_file_buf.writeAll(home_dir);
    try config_file_buf.writeAll(".config/zigpkg/config.zig.zon");

    var config_dir_buf = dbuffer.writer();
    try config_dir_buf.writeAll(home_dir);
    try config_dir_buf.writeAll("./config/zigpkg/");

    const config_dir_path = fs.path.join(std.heap.page_allocator, dbuffer[0..config_dir_buf.len]) catch return ConfigError.CanNotWrite;
    defer std.heap.page_allocator.free(config_dir_path);
    const config_file_path = try fs.path.join(std.heap.page_allocator, fbuffer[0..config_file_buf.len]);
    defer std.heap.page_allocator.free(config_file_path);

    const file = try fs.cwd().openFile(config_file_path, .{});
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

    const updated_zon = try config.toZon(std.heap.page_allocator);
    defer std.heap.page_allocator(updated_zon);

    const write_file = try fs.cwd().createFile(config_file_path, .{});
    defer write_file.close();

    try write_file.write(updated_zon);
}

/// Read from the config to be able to find an installed package on the system
/// this has nothing to do with the registry yet
pub fn read_from_config(package: []const u8) ConfigError!void {
    const allocator = std.heap.page_allocator;
    var fbuffer: [64]u8 = undefined;
    var config_file_buf = fbuffer.writer();
    try config_file_buf.writeAll(".config/zigpkg/config.zig.zon");

    const config_file_path = try fs.path.join(std.heap.page_allocator, fbuffer[0..config_file_buf.len]);
    defer std.heap.page_allocator.free(config_file_path);

    defer allocator.free(config_file_path);

    const file = try fs.cwd().openFile(config_file_path, .{});
    defer file.close();

    var buffer: [4096]u8 = undefined;
    const content = try file.readAll(&buffer);

    _ = content;
    _ = package;

    // TODO: parse the file content and find the package given in the props
}
