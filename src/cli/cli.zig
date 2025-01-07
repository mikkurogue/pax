const std = @import("std");
const Tuple = std.meta.Tuple;
const StrEql = std.mem.eql;

pub const SupportedCommands = enum {
    install,
    remove,
    list,
    // link - this is for p2 in roadmap.
};

pub const CliError = error{ UnsupportedCommand, MissingArgumentPackageName };

pub const Cli = struct {
    /// Run commands like
    /// zigpkg install <packagename>
    /// where a command has an input like a name etc.
    pub fn run(cmd: []const u8, package: ?[]const u8) !void {
        // TODO: Rework this into a switch to switch on the supported commands
        if (package == null) {
            return CliError.MissingArgumentPackageName;
        } else if (StrEql(u8, cmd, "install")) {
            try install(package.?);
            std.log.debug("Found command: {s} with value {s}", .{ cmd, package.? });
        } else if (StrEql(u8, cmd, "remove")) {
            try remove(package.?);
            std.log.debug("Found command: {s} with value {s}", .{ cmd, package.? });
        } else if (StrEql(u8, cmd, "link")) {
            try link(package.?);
            std.log.debug("Found command: {s} with value {s}", .{ cmd, package.? });
        }
    }

    /// run singluar commands only like list
    pub fn run_single(cmd: []const u8) !void {
        if (StrEql(u8, cmd, "list")) {
            try list();
        }
    }
};

/// install a package to the system (essentially mkdir ~/.zigpkgs/packages/<packagename>/ and place tarball here)
fn install(package: []const u8) !void {
    std.log.debug("install this package: {s} ", .{package});
}

/// remove a package from the system (essentially rm -rf ~/.zigpkgs/packages/<packagename>/)
fn remove(package: []const u8) !void {
    std.log.debug("remove this package: {s}", .{package});
}

/// Requires the cli to be navigated to a zig project. requires a build.zig.zon (and/or our own local packages.zig.zon)
fn link(package: []const u8) !void {
    std.log.debug("link package to current project: {s}", .{package});
}

/// list all insatlled packages on the system - these will be in ~/.zigpkg/packages/
fn list() !void {
    std.log.debug("list installed system packages", .{});
}
