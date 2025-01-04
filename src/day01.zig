const std = @import("std");
const ArrayList = std.ArrayList;
const expect = std.testing.expect;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("./data/day01/gh.txt", .{});
    defer file.close();

    const fileStat = try file.stat();
    const fileContent = try file.readToEndAlloc(allocator, fileStat.size);
    defer allocator.free(fileContent);

    const input = std.mem.trim(u8, fileContent, " \t\n\r");
    std.debug.print("Day 01, part 1: {}\n", .{try solveInternal(input, allocator)});
}

fn solveInternal(input: []const u8, allocator: std.mem.Allocator) !u32 {
    const movements = try parseInput(input, allocator);
    defer movements.deinit();

    var x: i32 = 0;
    var y: i32 = 0;
    var dir: Direction = .north;

    for (movements.items) |it| {
        switch (it.side) {
            .left => {
                switch (dir) {
                    .north => {
                        dir = .west;
                    },
                    .south => {
                        dir = .east;
                    },
                    .east => {
                        dir = .north;
                    },
                    .west => {
                        dir = .south;
                    },
                }
            },
            .right => {
                switch (dir) {
                    .north => {
                        dir = .east;
                    },
                    .south => {
                        dir = .west;
                    },
                    .east => {
                        dir = .south;
                    },
                    .west => {
                        dir = .north;
                    },
                }
            },
        }

        switch (dir) {
            .north => {
                y -= it.steps;
            },
            .south => {
                y += it.steps;
            },
            .east => {
                x += it.steps;
            },
            .west => {
                x -= it.steps;
            },
        }
    }

    return @abs(x) + @abs(y);
}

fn parseInput(input: []const u8, allocator: std.mem.Allocator) !ArrayList(Movement) {
    var movements = ArrayList(Movement).init(allocator);
    var it = std.mem.splitSequence(u8, input, ", ");
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

test "case 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const actual = try solveInternal("R2, L3", allocator);
    try expect(actual == 5);
}

test "case 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const actual = try solveInternal("R2, R2, R2", allocator);
    try expect(actual == 2);
}

test "case 3" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const actual = try solveInternal("R5, L5, R5, R3", allocator);
    try expect(actual == 12);
}
