const std = @import("std");
const config = @import("config.zig");

test "create_initial_config creates default config file" {
    const fs = std.fs;
    const allocator = std.testing.allocator;

    const home_dir = std.posix.getenv("HOME") orelse unreachable;
    const config_file_path = try fs.path.join(allocator, home_dir ++ ".config/zigpkg/config.zig.zon");
    defer allocator.free(config_file_path);

    try std.fs.cwd().deleteFile(config_file_path) catch {};

    try config.create_initial_config();

    var file = try fs.cwd().openFile(config_file_path, .{ .read = true });
    defer file.close();

    var buffer: [1024]u8 = undefined;
    const content = try file.readAll(&buffer);

    try std.testing.expect(std.mem.contains(content, "install_dir ="));
    try std.testing.expect(std.mem.contains(content, "cache_dir ="));
}

test "write_to_config handles install action" {
    const fs = std.fs;
    const allocator = std.testing.allocator;

    const home_dir = std.posix.getenv("HOME") orelse unreachable;
    const config_file_path = try fs.path.join(allocator, home_dir ++ ".config/zigpkg/config.zig.zon");
    defer allocator.free(config_file_path);

    // Ensure initial config exists
    try config.create_initial_config();

    try config.write_to_config("example-package", "install");

    var file = try fs.cwd().openFile(config_file_path, .{ .read = true });
    defer file.close();

    var buffer: [1024]u8 = undefined;
    const content = try file.readAll(&buffer);

    try std.testing.expect(std.mem.contains(content, "example-package"));
}

test "read_from_config verifies installed package" {
    const fs = std.fs;
    const allocator = std.testing.allocator;

    const home_dir = std.posix.getenv("HOME") orelse unreachable;
    const config_file_path = try fs.path.join(allocator, home_dir ++ ".config/zigpkg/config.zig.zon");
    defer allocator.free(config_file_path);

    // Ensure initial config and package installation
    try config.create_initial_config();
    try config.write_to_config("example-package", "install");

    try config.read_from_config("example-package");

    // If no error is thrown, the package exists, and the test passes
}
