const std = @import("std");
const parser = @import("parser.zig");

test "test writing to zon file" {
    const TStruct = struct { a: u8, b: u8 };

    const t = TStruct{
        .a = 0,
        .b = 1,
    };

    try parser.ZonParser.marshal(TStruct, t, "");
}
