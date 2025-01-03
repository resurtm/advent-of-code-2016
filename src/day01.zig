const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // const rawInput: []const u8 = "R2, L3";
    const rawInput: []const u8 = "R5, L5, R5, R3";

    const movements = try parseInput(rawInput, allocator);
    defer movements.deinit();

    for (movements.items, 0..) |it, idx| {
        std.debug.print("{} - {} - {}\n", .{ idx, it.side, it.steps });
    }
}

fn parseInput(rawInput: []const u8, allocator: std.mem.Allocator) !ArrayList(Movement) {
    var movements = ArrayList(Movement).init(allocator);
    var it = std.mem.splitSequence(u8, rawInput, ", ");
    while (it.next()) |x| {
        var movement = Movement{
            .side = Side.left,
            .steps = 0,
        };
        switch (x[0]) {
            'R' => {
                movement.side = Side.right;
            },
            'L' => {
                movement.side = Side.left;
            },
            else => {},
        }
        movement.steps = try std.fmt.parseInt(i32, x[1..], 10);
        try movements.append(movement);
    }
    return movements;
}

const Movement = struct { side: Side, steps: i32 };
const Side = enum { left, right };
const Direction = enum { north, south, east, west };
