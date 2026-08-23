const std = @import("std");

pub const BinSearch = struct {
    data: []const i32,

    pub fn init(data: []const i32) BinSearch {
        return .{ .data = data };
    }

    fn i32Order(a: i32, b: i32) std.math.Order {
        return std.math.order(a, b);
    }

    pub fn query_one(self: *const @This(), target: i32) i32 {
        const idx = std.sort.lowerBound(i32, self.data, target, i32Order);
        if (idx < self.data.len) return self.data[idx];
        return std.math.maxInt(i32);
    }
};
