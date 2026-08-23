const std = @import("std");
const searchInt = @import("interface.zig");
const loadValues = @import("load.zig").loadValues;

fn probe(algo_name: []const u8, data: []const i32, allocator: std.mem.Allocator) !void {
    const tag = std.meta.stringToEnum(searchInt.AlgoTag, algo_name) orelse return error.UnknownAlgo;
    switch (tag) {
        inline else => |t| {
            const Algo = searchInt.getAlgo(t);
            const index = try Algo.init(data, allocator);
            defer index.deinit(allocator);

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
                const result = searchInt.queryOne(Algo, &index, target);
                const time = timer.read();
                std.debug.print("found {d}, took {d}ns\n", .{ result, time });
            }
        },
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 3) {
        std.debug.print("Usage: {s} <algorithm> <data_path>\n", .{args[0]});
        return;
    }

    const data = try loadValues(allocator, args[2]);
    try probe(args[1], data, allocator);
}
