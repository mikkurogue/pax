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

    // NOTE: This is is just poc to get things started.

    if (args.len < 2) {
        std.log.warn("No commands provided\n", .{});
        process.exit(0);
    }

    if (args.len == 2) {
        // TODO: Handle error from Cli.run_single() as it can error "hard"
        // but only realistically on typos which we can handle in a different way
        try Cli.run_single(args[1]);
    }

    if (args.len < 3) {
        // TODO: Handle errors from Cli.run() as it can error "hard"
        const val = if (args.len > 2) args[2] else null;
        try Cli.run(args[1], val);
    }
}
