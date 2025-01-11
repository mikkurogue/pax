//! This is the parser file for the .zon extension files.
//! This is missing a few extra QOL features:
//! 1. We can not yet parse a nested struct as its own property - however we can probably
//! do this with some form of recursion.
//! 2. we can not yet parse arrays/slices properly (strings being the exception).
//! If we can import the file, as it is "comptime known"
//! meaning we can also extract the properties from it.

const std = @import("std");
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();
const Allocator = std.mem.Allocator;

const Parser = @This();

const START_ZON = ".{{\n";
const END_ZON = "}}\n";
const DELIMITERS = "\n,{},=,\r, ,    ";
const FILE_SUFFIX = ".zig.zon";

/// the initial ZonParser struct that contains the 2 members of
/// marshal_dynamic and parse_dynamic.
///
/// This struct will eventually also hold some meta data for the parser once implementation is
/// satisfactory.
pub const ZonParser = struct {
    /// Dynamically marshal a struct of type T to into a .zig.zon file format.
    /// file_name can be a maximum of 24 characters long
    pub fn marshal_dynamic(comptime T: type, input: T, file_name: []const u8) !void {
        var buf: [32]u8 = undefined;
        const buf_slice = try std.fmt.bufPrint(&buf, "{s}{s}", .{ file_name, FILE_SUFFIX });

        const file = try std.fs.cwd().createFile(buf_slice, .{});
        defer file.close();

        var writer = file.writer();

        try writer.print(START_ZON, .{});

        const type_info = @typeInfo(T);

        const struct_fields = type_info.@"struct".fields;
        inline for (struct_fields) |f| {
            const name = f.name;
            const val = @field(input, name);
            if (f.type == []const u8) {
                try writer.print("    .{s} = \"{s}\",\n", .{ name, val });
                break;
            }
            try writer.print("    .{s} = {},\n", .{ name, val });
        }
        try writer.print(END_ZON, .{});

        std.log.debug("Dynamic structure written to .zon file\n", .{});
    }

    /// Dyanimically read a .zig.zon file into a struct of type T.
    /// Returns an error union of anyerror or the struct of type T.
    pub fn parse_dynamic(comptime T: type, content: []const u8) !T {
        var result: T = undefined;

        const delimiters = DELIMITERS;
        var tokenizer = std.mem.tokenizeAny(u8, content, delimiters);

        inline for (@typeInfo(T).@"struct".fields) |field| {
            while (tokenizer.next()) |token| {
                if (token.len == 0 or token[0] != '.') continue;

                const field_name = token[1..];

                if (!std.mem.eql(u8, field.name, field_name)) continue;

                // skip if the token is an "=" symbol.
                const maybe_equals = tokenizer.next() orelse return error.InvalidFormat;

                if (!std.mem.eql(u8, maybe_equals, "=")) {
                    try assign_field_value(field.type, &@field(result, field.name), maybe_equals);
                } else {
                    const value_token = tokenizer.next() orelse return error.InvalidFormat;
                    try assign_field_value(field.type, &@field(result, field.name), value_token);
                }
                break;
            }
        }

        return result;
    }
};

/// Assign a field value to a provided field name from a struct. By passing the ptr and de-referencing
/// the pointer to be able to mut its value with the provided value.
/// all values must be provided as 'strings' but this will also assign and cast the value to the correct
/// type based on the FieldType type that is passed on comptime
fn assign_field_value(comptime FieldType: type, ptr: *FieldType, value: []const u8) !void {
    const type_info = @typeInfo(FieldType);

    switch (type_info) {
        .int => {
            var cleaned_value = std.ArrayList(u8).init(std.heap.page_allocator);
            defer cleaned_value.deinit();

            for (value) |c| {
                if (c != ',') {
                    try cleaned_value.append(c);
                }
            }
            ptr.* = try std.fmt.parseInt(FieldType, cleaned_value.items, 10);
        },
        .float => {
            ptr.* = try std.fmt.parseFloat(FieldType, value);
        },
        .pointer => |ptr_info| {
            if (ptr_info.size == .Slice and ptr_info.child == u8) {
                if (value.len >= 2 and value[0] == '"' and value[value.len - 1] == '"') {
                    const v = value[1 .. value.len - 1];
                    ptr.* = v;
                } else {
                    ptr.* = value;
                }
            } else {
                @compileError("Unsupported pointer type");
            }
        },
        else => @compileError("Unsupported type"),
    }
}

test "test writing to zon file" {
    const TStruct = struct { x: i32, y: i32, z: f32, s: []const u8 };

    const t = TStruct{ .x = 10, .y = 999, .z = 3.14, .s = "hello" };

    try ZonParser.marshal_dynamic(TStruct, t, "test_file");
}

test "parse dynamic .zon file" {
    const MyStruct = struct { x: i32, y: i32, z: f32, s: []const u8 };
    const file = try std.fs.cwd().openFile("output_dynamic.zig.zon", .{});
    defer file.close();

    const content = try file.readToEndAlloc(std.testing.allocator, 512);
    defer std.testing.allocator.free(content);
    const parsed = try ZonParser.parse_dynamic(MyStruct, content);

    try std.testing.expect(std.mem.eql(u8, parsed.s, "hello"));
}
