const std = @import("std");
const searchInt = @import("interface.zig");
const utils = @import("utils.zig");
const loadValues = @import("load.zig").loadValues;

fn bench(algo_name: []const u8, data: []const i32, n: usize, allocator: std.mem.Allocator) !void {
    const tag = std.meta.stringToEnum(searchInt.AlgoTag, algo_name) orelse return error.UnknownAlgo;
    switch (tag) {
        inline else => |t| {
            const Algo = searchInt.getAlgo(t);
            const index = try Algo.init(data, allocator);
            defer index.deinit(allocator);

            const queries = try utils.genRandI32Nums(n, allocator);
            defer allocator.free(queries);
            var out = try allocator.alloc(i32, n);
            defer allocator.free(out);
            var timer = try std.time.Timer.start();
            searchInt.query(Algo, &index, queries, &out);
            const time = timer.read();
            std.debug.print("finished {d} queries, took {d}ns, {d}ns per query\n", .{ n, time, time / n });
        },
    }
}

pub fn main() !void {
    var pga = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = pga.deinit();
    const allocator = pga.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 4) {
        std.debug.print("Usage {s} <algo_name> <data_path> <num_queries>\n", .{args[0]});
    }

    const data = try loadValues(allocator, args[2]);
    defer allocator.free(data);
    const n = try std.fmt.parseInt(usize, args[3], 10);
    try bench(args[1], data, n, allocator);
}
