//! This is the parser file for the .zon extension files.
//! We need to still figure out how we can read the file(s)
//! even if they are not in the project directory.
//!
//! This is because using json is fine, but parsing json into
//! the zon format for a struct seems to be a pain in the ass.
//! If we can import the file, as it is "comptime known"
//! meaning we can also extract the properties from it.

const std = @import("std");

const Parser = @This();

pub const ZonParser = struct {
    /// marshal a struct and write it to a file
    pub fn marshal(comptime T: type, input: T, output: []const u8) !void {
        _ = input;
        _ = output;
    }

    // parse an input file and marshal this into a struct of type T
    pub fn parse(comptime T: type, input: anytype) !T {
        _ = input;
    }
};
