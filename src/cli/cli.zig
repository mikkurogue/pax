const std = @import("std");
const Tuple = std.meta.Tuple;
const StrEql = std.mem.eql;
const stdout = std.io.getStdOut().writer();
const init_prj = @import("./init_prj.zig");

pub const Cli = @This();

/// The potential CLI errors that can occur.
/// UnsupportedCommand is a command that is not available in the SupportedCommands enum.
pub const CliError = error{ UnsupportedCommand, MissingArgumentPackageName, UnsupportedOrInvalidCommand };
/// All supported commands
pub const SupportedCommands = enum { install, remove, list, link, help, init };

/// Basic CommandRunner struct to make sure we use the correct commands
/// Command syntaxx is `pax install <packagename>` for instance.
pub const CommandRunner = struct {
    /// Run commands like
    /// pax install <packagename>
    /// where a command has an input like a name etc.
    pub fn run(cmd: []const u8, package: ?[]const u8) !void {
        if (package == null) {
            return CliError.MissingArgumentPackageName;
        }

        const case = std.meta.stringToEnum(SupportedCommands, package.?) orelse return CliError.UnsupportedCommand;

        std.log.debug("case: {any}", .{case});

        switch (case) {
            .install => {
                try install(package.?);
                std.log.debug("Found command: {s} with value {s}", .{ cmd, package.? });
            },
            .remove => {
                try remove(package.?);
                std.log.debug("Found command: {s} with value {s}", .{ cmd, package.? });
            },
            .link => {
                try link(package.?);
                std.log.debug("Found command: {s} with value {s}", .{ cmd, package.? });
            },
            else => return CliError.UnsupportedCommand,
        }
    }

    /// run singluar commands only like list
    pub fn run_single(cmd: []const u8) !void {
        if (StrEql(u8, cmd, "list")) {
            try list();
        } else if (StrEql(u8, cmd, "help")) {
            try print_help();
        } else if (StrEql(u8, cmd, "init")) {
            try init_prj.scaffold("hehe.zig.zon");
        }
    }
};

/// install a package to the system (essentially mkdir ~/.config/pax/packages/<packagename>/ and place tarball here)
fn install(package: []const u8) !void {
    std.log.debug("install this package: {s} ", .{package});
}

/// remove a package from the system (essentially rm -rf ~/.config/pax/packages/<packagename>/)
fn remove(package: []const u8) !void {
    std.log.debug("remove this package: {s}", .{package});
}

/// Requires the cli to be navigated to a zig project. requires a build.zig.zon (and/or our own local packages.zig.zon)
fn link(package: []const u8) !void {
    std.log.debug("link package to current project: {s}", .{package});
}

/// list all insatlled packages on the system - these will be in ~/.config/paxpackages/
fn list() !void {
    std.log.debug("list installed system packages", .{});
}

fn print_help() !void {
    try stdout.print("List of commands that are supported here pls", .{});
}
