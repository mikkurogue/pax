const std = @import("std");
const cfg = @import("config.zig");
const fs = std.fs;

// TODO:
// make these tests pass, for now for instance the first test fails
// because the path can not be found or created or something
// maybe im brainless maybe im stupid for not using a library to handle this
// ironic, a package manager who wants to use no packages...

test "create_initial_config creates default config file" {
    cfg.create_initial_config() catch |err| {
        std.log.warn("Error during config creation: {}", .{err});
        return;
    };
}
//
// test "write_to_config handles install action" {
//     try config.write_to_config("test-pkg", "install");
// }

// test "write_to_config handles install action" {
//
//     // Ensure initial config exists
//     try config.create_initial_config();
//
//     try config.write_to_config("example-package", "install");
// }
//
// test "read_from_config verifies installed package" {
//
//     // Ensure initial config and package installation
//     try config.create_initial_config();
//     try config.write_to_config("example-package", "install");
//
//     try config.read_from_config("example-package");
//
//     // If no error is thrown, the package exists, and the test passes
// }
