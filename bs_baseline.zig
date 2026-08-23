const std = @import("std");

pub const BinSearch = struct {
    data: []const i32,

    pub fn init(data: []const i32, _: std.mem.Allocator) !BinSearch {
        return .{ .data = data };
    }

    pub fn deinit(_: *const @This(), _: std.mem.Allocator) void {}

    fn i32Order(a: i32, b: i32) std.math.Order {
        return std.math.order(a, b);
    }

    pub fn queryOne(self: *const @This(), target: i32) i32 {
        const idx = std.sort.lowerBound(i32, self.data, target, i32Order);
        if (idx < self.data.len) return self.data[idx];
        return std.math.maxInt(i32);
    }
};
