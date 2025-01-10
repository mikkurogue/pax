const std = @import("std");
const fs = std.fs;
const Tuple = std.meta.Tuple;
const StrEql = std.mem.eql;
const Allocator = std.mem.Allocator;
const pkg = @import("package.zig");

pub const cfg = @This();

pub const ConfigError = error{ ConfigurataionAlreadyExists, CanNotRead, CanNotWrite, CanNotCreatePackagesDir };
const install_dir = "~/.config/pax/packages";
const cache_dir = "~/.config/pax/cache";

const config_file_path = &[_][]const u8{
    "~",
    ".config",
    "pax",
    "config.zig.zon",
};

// this is probably not necessary
pub const Config = struct {
    install_dir: []const u8,
    cache_dir: []const u8,

    // this should be of type []pkg.Package.
    // i just dont know yet how to make the slice dynamic
    packages: std.ArrayList(pkg.Package),

    /// Try to use this in reference to the struct when in it.
    /// Should clear up confusion when also using other structs inside
    /// the struct at some point.
    const Self = @This();

    /// init a new configuration.
    pub fn init(idir: []const u8, cdir: []const u8, allocator: Allocator) !Self {
        return .{ .install_dir = idir, .cache_dir = cdir, .packages = std.ArrayList(pkg.Package).init(allocator) };
    }

    /// clean up resources
    pub fn deinit(self: *Self) void {
        self.packages.deinit();
    }

    /// append a package to the arraylist
    pub fn append_pkg(self: *Self, p: pkg.Package) !void {
        try self.packages.append(p);
    }

    /// Migrate this to the parser to write the struct instead of appending to a string buffer.
    pub fn toZon(self: *Self, allocator: std.mem.Allocator) ![]const u8 {
        // _ = self;
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        try buffer.appendSlice(".{\n");

        try buffer.appendSlice("    .install_dir = \"" ++ "\"");
        try buffer.appendSlice(self.install_dir);
        try buffer.appendSlice("\",\n");

        try buffer.appendSlice("    .cache_dir = \"");
        try buffer.appendSlice(self.cache_dir);
        try buffer.appendSlice("\",\n");

        try buffer.appendSlice("    .packages = \"");
        try buffer.appendSlice(self.packages);
        try buffer.appendSlice("\",\n");

        try buffer.appendSlice("}\n");

        return buffer.toOwnedSlice();
    }
};

pub fn create_initial_config() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Resolve `~` to the home directory
    const home_opt = std.posix.getenv("HOME") orelse unreachable;
    const home: []const u8 = home_opt;
    const cfg_dir = try fs.path.join(allocator, &.{ home, ".config", "pax" });
    const cfg_file_dir = try fs.path.join(allocator, &.{ home, ".config", "pax", "config.zig.zon" });
    defer allocator.free(cfg_dir);
    defer allocator.free(cfg_file_dir);

    var file = fs.cwd().createFile(cfg_file_dir, .{}) catch |err| switch (err) {
        // todo add the create file here if it doesnt exist
        error.PathAlreadyExists => return,
        else => return err,
    };
    defer file.close();

    // this is now broken because we dont use the default anymore. we need to figure out what to do
    // var default_cfg = Config.init(install_dir, cache_dir, allocator);
    // const config_zon = try default_cfg.toZon(allocator);
    // defer allocator.free(config_zon);
    // try file.writeAll(config_zon);
}

/// Write to the config in ~/.config/pax/config.zig.zon
/// This should be like writing a newly installed package
/// or removing a package
/// (upgrade package probably at a later point)
pub fn write_to_config(package: []const u8, action: []const u8) !void {
    _ = package;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const config_file = try fs.path.join(allocator, config_file_path);
    defer allocator.free(config_file);

    const file = try fs.cwd().openFile(config_file, .{});
    defer file.close();

    var buffer: [4096]u8 = undefined;
    const content = try file.readAll(&buffer);
    _ = content;

    var config = Config.init(install_dir, cache_dir, allocator);
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
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

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
