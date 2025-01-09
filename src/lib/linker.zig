/// This file is the initial linker, to link packages to a zig project
/// from the cli.
/// aka when the command `zigpkg link <package>` is fired
/// this has the logic to actually link the package to the project,
/// update the build file and build the project to complete the link
/// its not as seamless of an idea that npm has for isntance
/// but it gives the user more control
/// we can automate the zigpkg install command to also automtically link
/// if we are in a zig project directory
const std = @import("std");
const pkg = @import("package.zig");

pub const Linker = @This();

/// Error set for the linker
/// NoProjectFound - meaning that whatever directory we are in is not a zig project so linker can not link anything.
pub const LinkerError = error{NoProjectFound};

/// Link the package to the current project directory
/// Can return error: NoProjectFound
pub fn link_package(package: pkg.Package) anyerror!void {

    // TODO: get cwd, get packages.zig.zon (or dependencies.zig.zon) and link the
    // package to this. then link that to the build.zig.zon to link the dep
    // correctly to the project.

    // replace this logic with the actual cwd logic
    if (true) {
        return LinkerError.NoProjectFound;
    }
    pkg.add_package(package);
}

pub fn unlink_package(package_name: []const u8) anyerror!void {
    // TODO:
    // get cwd, remove the package from packages.zig.zon (or dependencies.zig.zon)
    // and remove it from the build.zig.zon too. If any local files like tarballs, header files etc
    // are added to the local project, then remove these files too.

    // replace this logic with the actual cwd logic
    if (true) {
        return LinkerError.NoProjectFound;
    }

    pkg.remove_package(package_name);
}
