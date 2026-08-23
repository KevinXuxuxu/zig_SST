// zig run gen.zig -- 100000 &> data.txt
const std = @import("std");
const utils = @import("utils.zig");

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

    const nums = try utils.genRandI32Nums(n, allocator);
    defer allocator.free(nums);

    std.mem.sort(i32, nums, {}, std.sort.asc(i32));
    for (nums) |x| std.debug.print("{d}\n", .{x});
}
