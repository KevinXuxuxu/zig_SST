const std = @import("std");

pub fn loadValues(allocator: std.mem.Allocator, path: []const u8) ![]i32 {
    const io = std.testing.io;
    const file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);
    var buf: [64]u8 = undefined;
    var reader = file.reader(io, &buf);

    // read the first line for number of values
    var line = try reader.interface.takeDelimiter('\n') orelse return error.UnexpectedEOF;
    const n = try std.fmt.parseInt(usize, line, 10);
    std.debug.print("reading {s} values\n", .{line});
    const values = try allocator.alloc(i32, n);
    for (values) |*x| {
        line = try reader.interface.takeDelimiter('\n') orelse return error.UnexpectedEOF;
        x.* = try std.fmt.parseInt(i32, line, 10);
    }
    return values;
}
