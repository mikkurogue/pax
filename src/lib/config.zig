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
// this is probably not necessary
pub const Config = struct {
    install_dir: []const u8,
    cache_dir: []const u8,

    const Self = @This();

    pub fn default() Self {
        return Config{
            .install_dir = "~/.config/zigpkg/packages",
            .cache_dir = "~/.config/zigpkg/cache",
        };
    }

    pub fn toZon(self: *Self, allocator: std.mem.Allocator) ![]const u8 {
        _ = self;
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        try buffer.appendSlice(".{\n");

        try buffer.appendSlice("    .install_dir = \"");

        try buffer.appendSlice(install_dir);

        try buffer.appendSlice("\",\n");

        try buffer.appendSlice("    .cache_dir = \"");
        try buffer.appendSlice(cache_dir);
        try buffer.appendSlice("\"\n}\n");

        return buffer.toOwnedSlice();
    }
};

pub fn create_initial_config() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Resolve `~` to the home directory
    const home_opt = std.posix.getenv("HOME") orelse unreachable;
    const home: []const u8 = home_opt;
    const cfg_dir = try fs.path.join(allocator, &.{ home, ".config", "zigpkg" });
    const cfg_file_dir = try fs.path.join(allocator, &.{ home, ".config", "zigpkg", "config.zig.zon" });
    defer allocator.free(cfg_dir);
    defer allocator.free(cfg_file_dir);

    var file = fs.cwd().createFile(cfg_file_dir, .{}) catch |err| switch (err) {
        // todo add the create file here if it doesnt exist
        error.PathAlreadyExists => return,
        else => return err,
    };
    defer file.close();

    var cfg = Config.default();
    const config_zon = try cfg.toZon(allocator);
    defer allocator.free(config_zon);
    try file.writeAll(config_zon);
}

/// Write to the config in ~/.config/zigpkg/config.zig.zon
/// This should be like writing a newly installed package
/// or removing a package
/// (upgrade package probably at a later point)
pub fn write_to_config(package: []const u8, action: []const u8) !void {
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

    const size = try write_file.write(updated_zon);
    std.log.debug("Size: {d}", .{size});
}

/// Read from the config to be able to find an installed package on the system
/// this has nothing to do with the registry yet
pub fn read_from_config(package: []const u8) !void {
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
