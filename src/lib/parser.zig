//! This is the parser file for the .zon extension files.
//! We need to still figure out how we can read the file(s)
//! even if they are not in the project directory.
//!
//! This is because using json is fine, but parsing json into
//! the zon format for a struct seems to be a pain in the ass.
//! If we can import the file, as it is "comptime known"
//! meaning we can also extract the properties from it.

const std = @import("std");
const assert = std.debug.assert;

const Parser = @This();

pub const ZonParser = struct {
    /// marshal a struct and write it to a file
    /// T must be a struct, so need to add some form of validation
    pub fn marshal(comptime T: type, input: T, output: []const u8) !void {
        // figure out how we can assert the type of input to be a struct
        // it isnt necessarily an anonymous struct
        // comptime assert(@typeInfo(@TypeOf(input)).@"struct".layout != .auto);
        // For no ignore the output as this needs more testing
        _ = output;

        // Open the .zon file
        const file = try std.fs.cwd().createFile("output.zig.zon", .{});

        defer file.close();

        // Create a writer for the file
        var writer = file.writer();

        // Serialize to .zon format
        try writer.print(".{{\n    .a = {},\n    .b = {}\n}}\n", .{ input.a, input.b });

        std.debug.print("Structure written to .zon file\n", .{});
    }

    // parse an input file and marshal this into a struct of type T
    // T must be a struct, so need to add some form of validation
    pub fn parse(comptime T: type, input: anytype) !T {
        _ = input;
    }
};
