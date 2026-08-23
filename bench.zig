const std = @import("std");

fn loadValues(allocator: std.mem.Allocator, path: []const u8) ![]i32 {
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

const BinSearch = @import("bs_baseline.zig").BinSearch;

fn probe(algo_name: []const u8, data: []const i32) !void {
    if (std.mem.eql(u8, algo_name, "binary_search")) return probeImpl(BinSearch, data);
    std.debug.print("unknown algo: {s}\n", .{algo_name});
    return error.UnknownAlgo;
}

fn probeImpl(comptime Algo: type, data: []const i32) !void {
    const index = Algo.init(data);

    std.debug.print("probe mode ({s}): enter queries one per line ('quit' to exit)\n", .{@typeName(Algo)});

    var timer = try std.time.Timer.start();
    var buf: [64]u8 = undefined;
    const io = std.testing.io;
    var reader = std.Io.File.stdin().reader(io, &buf);
    while (try reader.interface.takeDelimiter('\n')) |line| {
        const target = std.fmt.parseInt(i32, line, 10) catch |err| switch (err) {
            error.Overflow => {
                std.debug.print("Invalid i32 input: {s}\n", .{line});
                continue;
            },
            else => |e| return e,
        };
        timer.reset();
        const result = BinSearch.query_one(&index, target);
        const time = timer.read();
        std.debug.print("found {d}, took {d}ns\n", .{ result, time });
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = try loadValues(allocator, "data.txt");
    try probe("binary_search", data);
}
