const std = @import("std");
const os = std.os;
const process = std.process;
const Cli = @import("cli/cli.zig").Cli;

const StrEql = std.mem.eql;

const CliError = @import("cli/cli.zig").CliError;
const SupportedCommands = @import("cli/cli.zig").SupportedCommands;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 1) {
        std.log.warn("No commands provided\n", .{});
        process.exit(0);
    }

    if (StrEql(u8, args[1], "install")) {
        const val = if (args.len > 2) args[2] else null;
        try Cli.run(args[1], val);
    }

    // std.log.debug("there are {d} args: \n", .{args.len});
    //
    // for (args) |arg| {
    //     std.log.debug("    {s}\n", .{arg});
    // }

}
