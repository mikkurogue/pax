const std = @import("std");
const config = @import("config.zig");
const fs = std.fs;

test "create_initial_config creates default config file" {
    try config.create_initial_config();
}

test "write_to_config handles install action" {

    // Ensure initial config exists
    try config.create_initial_config();

    try config.write_to_config("example-package", "install");
}

test "read_from_config verifies installed package" {

    // Ensure initial config and package installation
    try config.create_initial_config();
    try config.write_to_config("example-package", "install");

    try config.read_from_config("example-package");

    // If no error is thrown, the package exists, and the test passes
}
