const std = @import("std");

pub const RegistryError = error{
    CanNotReach,
    NoConnection, // this is the same as above i think but for now lets keep it
    PackageNotFound,
    NoAccessToPackage,
};

/// Find a package in the registry TBD where and what this is
/// maybe just a simple github repo with a list of packages
/// that people can add to themselves with PR's?
/// or an actual registry site?
/// idk yet
pub fn find_in_registry(package: []const u8) RegistryError!void {
    _ = package;
}
