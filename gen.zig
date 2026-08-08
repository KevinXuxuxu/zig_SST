// zig run gen.zig -- 100000 &> data.txt
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <N>\n", .{args[0]});
        return;
    }

    const n = try std.fmt.parseInt(usize, args[1], 10);
    std.debug.print("{d}\n", .{n});

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    for (0..n) |_| {
        const value = rand.intRangeAtMost(i32, std.math.minInt(i32), std.math.maxInt(i32));
        std.debug.print("{d}\n", .{value});
    }
}
