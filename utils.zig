const std = @import("std");

pub fn genRandI32Nums(n: usize, allocator: std.mem.Allocator) ![]i32 {
    const nums = try allocator.alloc(i32, n);

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    for (nums) |*x| x.* = rand.intRangeAtMost(i32, std.math.minInt(i32), std.math.maxInt(i32));
    return nums;
}
