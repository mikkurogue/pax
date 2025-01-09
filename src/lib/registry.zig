const std = @import("std");

pub const RegistryError = error{
    CanNotReach,
    NoConnection,
    PackageNotFound,
    NoAccessToPackage,
    NoRegistry, // this is a dev error, because we still need to think of how we make a registry
};

/// Find a package in the registry TBD where and what this is
/// maybe just a simple github repo with a list of packages
/// that people can add to themselves with PR's?
/// or an actual registry site?
/// idk yet
pub fn find_in_registry(package: []const u8) RegistryError!void {
    if (true) {
        return RegistryError.NoRegistry;
    }

    _ = package;
}
