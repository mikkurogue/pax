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
const DELIMITERS = "\n,{},=,\r, ,    ";

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
    pub fn parse_dynamic(comptime T: type, content: []const u8) !T {
        var result: T = undefined;

        const delimiters = DELIMITERS;
        var tokenizer = std.mem.tokenizeAny(u8, content, delimiters);

        inline for (@typeInfo(T).@"struct".fields) |field| {
            while (tokenizer.next()) |token| {
                if (token.len == 0 or token[0] != '.') continue;

                const field_name = token[1..];

                if (!std.mem.eql(u8, field.name, field_name)) continue;

                // Skip any potential equals sign token
                const maybe_equals = tokenizer.next() orelse return error.InvalidFormat;

                if (!std.mem.eql(u8, maybe_equals, "=")) {
                    // If it's not an equals sign, it's our value
                    try parseAndAssignValue(field.type, &@field(result, field.name), maybe_equals);
                } else {
                    const value_token = tokenizer.next() orelse return error.InvalidFormat;
                    try parseAndAssignValue(field.type, &@field(result, field.name), value_token);
                }
                break;
            }
        }

        return result;
    }
};

fn parseAndAssignValue(comptime FieldType: type, ptr: *FieldType, value: []const u8) !void {
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

    try ZonParser.marshal_dynamic(TStruct, t, "");
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
