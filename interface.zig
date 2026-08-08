const std = @import("std");

pub fn queryOne(comptime Impl: type, self: *const Impl, target: i32) i32 {
    if (@hasDecl(Impl, "queryOne")) return Impl.queryOne(self, target);
    const single: [1]i32 = .{target};
    var out: [1]i32 = undefined;
    query(Impl, self, &single, &out);
    return out[0];
}

pub fn query(comptime Impl: type, self: *const Impl, queries: []const i32, out: []i32) void {
    if (@hasDecl(Impl, "query")) {
        return Impl.query(self, queries, out);
    }
    for (queries, out) |q, *o| o.* = queryOne(Impl, self, q);
}

test "interface instantiation" {
    const Dummy = struct {
        pub fn queryOne(self: *const @This(), target: i32) i32 {
            _ = self;
            return target;
        }
    };
    var d = Dummy{};
    try std.testing.expectEqual(@as(i32, 42), queryOne(Dummy, &d, 42));
}
