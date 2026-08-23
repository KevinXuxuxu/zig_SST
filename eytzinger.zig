const std = @import("std");

pub const Eytzinger = struct {
    data: []align(64) i32,

    pub fn init(sorted: []const i32, allocator: std.mem.Allocator) !Eytzinger {
        const n = sorted.len;
        var data = try allocator.alignedAlloc(i32, .@"64", n + 1);

        // sentinel
        data[0] = std.math.maxInt(i32);

        // go to the left-most node
        var i: usize = 1;
        while (2 * i <= n) i *= 2;

        for (sorted) |v| {
            data[i] = v;
            if (2 * i + 1 <= n) {
                i = 2 * i + 1;
                while (2 * i <= n) i *= 2;
            } else {
                while (i % 2 == 1) i /= 2;
                i /= 2;
            }
        }
        return .{ .data = data };
    }

    pub fn deinit(self: *const @This(), allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn queryOne(self: *const @This(), target: i32) i32 {
        var i: usize = 1;
        const block = 1 << 4;

        // prefetch first L levels
        while (block * i < self.data.len) {
            i = 2 * i + @as(usize, @intFromBool(target > self.data[i]));
            @prefetch(self.data.ptr + block * i, .{
                .rw = .read,
                .locality = 3,
                .cache = .data,
            });
        }
        while (i < self.data.len) {
            i = 2 * i + @as(usize, @intFromBool(target > self.data[i]));
        }
        while (i % 2 == 1) i /= 2;
        if (i > 0) return self.data[i / 2];
        return std.math.maxInt(i32);
    }
};
