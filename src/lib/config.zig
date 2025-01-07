const std = @import("std");

const Tuple = std.meta.Tuple;

pub const ConfigError = error{ ConfigurataionAlreadyExists, CanNotRead, CanNotWrite, CanNotCreatePackagesDir };

/// Create an initial config in ~/.zigpkg/config.zig.zon
pub fn create_initial_config() ConfigError!void {}

/// Write to the config in ~/.zigpkg/config.zig.zon
/// This should be like writing a newly installed package
/// or removing a package
/// (upgrade package probably at a later point)
pub fn write_to_config() ConfigError!void {}

/// Read from the config to be able to find an installed package on the system
/// this has nothing to do with the registry yet
pub fn read_from_config() ConfigError!void {}
