const std = @import("std");

pub const Pkg = @This();

pub const Package = struct { package_name: []const u8, package_version: []const u8, package_url: []const u8 };

pub fn read_package_metadata(package_name: []const u8) !Package {

    // TODO:
    // read package metadata from the local project
    // should return the Package struct

    // placeholder for now
    return Package{ .package_name = package_name, .package_version = "0.0.0", .package_url = "github.com/mikkurogue" };
}

pub fn read_system_package_data(package_name: []const u8) !Package {

    // TODO:
    // Read package metadata from a package that is installed on the system
    // the install path then is ~/.config/pax/packages

    // placeholder for now
    return Package{ .package_name = package_name, .package_version = "0.0.0", .package_url = "github.com/mikkurogue" };
}

pub fn remove_package(package_name: []const u8) !void {
    _ = package_name;

    // TODO:
    // Remove a package from the local project. see the linker method for what this body needs to do
}

pub fn remove_sys_package(package_name: []const u8) !void {
    _ = package_name;

    // TODO:
    // Remove a package from the system located in the config folder. Also remove cached entry (if we have caching ever implemented).
}

pub fn add_package(package: Package) !void {
    _ = package;

    // TODO:
    // Add a package to the local project that is the cwd for the cli.
}

pub fn add_sys_package(package: Package) !void {
    _ = package;

    // TODO:
    // Add a package to the system located in the config folder.
}

/// list all packages in a neat tuple array [name, version]
/// and return this
pub fn list_all_packages() !void {}

/// Create a local cache of packages
/// Not sure yet how we want to do this
pub fn cache_packages() !void {}

/// a function to clean up packages that are "stale"
/// tbd: how do we determine packages installed on the system are
/// stale?
pub fn clean_packages() !void {}

// upgrade all possible packages by checking version numbers
// against what is in the registry
// use list_all_packages() to get a list of all installed packages on the system
// and then use upgrade_package() while iterating over the list to upgrade.
// do not prompt user for each upgrade, just do the upgrade
pub fn upgrade_packages() !void {}

/// Upgrade a single package - this is meant to be the lib function
/// to the cli command `pax upgrade <packagename>`
/// fetch the package version currently installed on the system
/// and check this against the registry version
/// if local is higher then return "Currently installed version is newer"
/// if local is lower then prompt user with question "Upgrade X to version x.x.x?"
/// this is essentially to be used in the upgrade_packages() function above
/// by looping over all known packages
pub fn upgrade_package(package_name: []const u8, confirm: bool) !void {
    _ = package_name;
    _ = confirm;
}
