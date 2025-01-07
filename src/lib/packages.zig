const std = @import("std");

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
/// to the cli command `zigpkg upgrade <packagename>`
/// fetch the package version currently installed on the system
/// and check this against the registry version
/// if local is higher then return "Currently installed version is newer"
/// if local is lower then prompt user with question "Upgrade X to version x.x.x?"
/// this is essentially to be used in the upgrade_packages() function above
/// by looping over all known packages
pub fn upgrade_package(package: []const u8, confirm: bool) !void {
    _ = package;
    _ = confirm;
}
