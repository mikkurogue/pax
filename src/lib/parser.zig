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
const stdout = std.io.getStdOut().writer();

const Parser = @This();

const START_ZON = ".{{\n";
const END_ZON = "}}\n";
const DELIMITERS = "\n,{},=";

pub const ZonParser = struct {
    /// Dynamically marshal a struct of type T to into a .zig.zon file format.
    pub fn marshal_dynamic(comptime T: type, input: T, output: []const u8) !void {
        // Ignore output for now
        _ = output;

        // Create the output file
        const file = try std.fs.cwd().createFile("output_dynamic.zig.zon", .{});
        defer file.close();

        var writer = file.writer();

        try writer.print(START_ZON, .{});

        const type_info = @typeInfo(T);

        const struct_fields = type_info.@"struct".fields;
        inline for (struct_fields) |f| {
            const name = f.name;
            const val = @field(input, name);
            try writer.print("    .{s} = {},\n", .{ name, val });
        }
        try writer.print(END_ZON, .{});

        std.log.debug("Dynamic structure written to .zon file\n", .{});
    }

    /// Dyanimically read a .zig.zon file into a struct of type T.
    pub fn parse_dynamic(comptime T: type, input: []const u8) !T {
        const file = try std.fs.cwd().openFile(input, .{});
        defer file.close();

        const content = try file.readToEndAlloc(std.heap.page_allocator, 512);
        defer std.heap.page_allocator.free(content);

        var result: T = @as(T, undefined);

        const delimiters = DELIMITERS;
        var tokenizer = std.mem.tokenizeAny(u8, content, delimiters);

        // FIXME: This needs to parse the values correctly, somehow the field type is known
        // but the value token isnt parsed correctly.
        // i.e. if the value_token is 0 (or 1 doesnt matter) then the output is 170
        // idk what im doing wrong here
        inline for (@typeInfo(T).@"struct".fields) |field| {
            while (tokenizer.next()) |token| {
                if (token.len == 0 or token[0] != '.') continue;

                const field_name = token[1..];
                if (!std.mem.eql(u8, field.name, field_name)) continue;

                const value_token = tokenizer.next() orelse return error.InvalidFormat;

                switch (field.type) {
                    u8, u16, u32, u64 => {
                        @field(result, field.name) = try std.fmt.parseInt(field.type, value_token, 10);
                    },
                    f32, f64 => {
                        @field(result, field.name) = try std.fmt.parseFloat(field.type, value_token);
                    },
                    []const u8 => {
                        @field(result, field.name) = value_token;
                    },
                    else => @compileError("Unsupported type"),
                }
                break;
            }
        }

        return result;
    }
};

test "test writing to zon file" {
    const TStruct = struct { x: u8, y: u16, z: f32 };

    const t = TStruct{
        .x = 10,
        .y = 300,
        .z = 3.14,
    };

    try ZonParser.marshal_dynamic(TStruct, t, "");
}

test "parse dynamic .zon file" {
    const MyStruct = struct {
        x: u8,
        y: u16,
        z: f32,
    };

    const parsed = try ZonParser.parse_dynamic(MyStruct, "output_dynamic.zig.zon");

    std.log.warn("PARSED X: {d}", .{parsed.x});
}
