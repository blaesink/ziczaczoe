const std = @import("std");

/// Lets us toggle between 1 and 2.
const Board = struct {
    tiles: [3][3]u8 = [3][3]u8{
        [3]u8{ 32, 32, 32 },
        [3]u8{ 32, 32, 32 },
        [3]u8{ 32, 32, 32 },
    },

    const Self = @This();

    pub fn init() Self {
        return Self{};
    }

    pub fn place(
        self: *Self,
        char: u8,
        x: u8,
        y: u8,
    ) !void {
        if (self.tiles[x][y] != 32) // not "space"
            return error.SpaceOccupied;
        self.tiles[x][y] = char;
    }

    /// Checks to see if there are any win conditions.
    pub fn checkForWin(self: Self) bool {
        // Fast check to see if a row has all of the same char, if so, then we win.
        for (self.tiles) |row| {
            const x, const y, const z = row;

            if (x == 32 or y == 32 or z == 32)
                continue;

            if (x == y and y == z)
                return true;
        }

        // Then, check the columns
        for (0..self.tiles.len) |i| {
            const x = self.tiles[0][i];
            const y = self.tiles[1][i];
            const z = self.tiles[2][i];

            if (x == 32 or y == 32 or z == 32)
                continue;

            if (x == y and y == z)
                return true;
        }

        // Last check is diagonals. We only have two, so we just check those.
        diag_1: {
            const x = self.tiles[0][0];
            const y = self.tiles[1][1];
            const z = self.tiles[2][2];

            if (x == 32 or y == 32 or z == 32)
                break :diag_1;

            if (x == y and y == z)
                return true;
        }
        diag_2: {
            const x = self.tiles[0][2];
            const y = self.tiles[1][1];
            const z = self.tiles[2][0];

            if (x == 32 or y == 32 or z == 32)
                break :diag_2;

            if (x == y and y == z)
                return true;
        }
        // Too bad!
        return false;
    }

    pub fn format(
        self: Self,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        for (self.tiles) |row| {
            try writer.print("|{c}|{c}|{c}|\n", .{ row[0], row[1], row[2] });
        }
    }
};

const tile_chars = [2]u8{ 'X', 'O' };

fn isValidNumber(c: u8) bool {
    return (47 < c) and (c < 58);
}

fn parseMove(msg: []const u8) ![2]u8 {
    var buf: [2]u8 = [_]u8{ 0, 0 };

    const x = msg[0];
    const y = msg[2];

    if (!isValidNumber(x) or !isValidNumber(y))
        return error.InvalidInput;

    // Pretend we're just gonna do nice things and do input as "X Y".
    buf[0] = x - 48;
    buf[1] = y - 48;

    return buf;
}

pub fn main() !void {
    var in_buf: [16]u8 = undefined;

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var board = Board.init();

    // Oscillates between 1 and 0 via the xor in the loop;
    var player: u8 = 0;

    while (true) {
        try stdout.print("===Player {d}===\n", .{player + 1});
        try stdout.print("Enter your move (x y): ", .{});

        if (try stdin.readUntilDelimiterOrEof(&in_buf, '\n')) |msg| {
            const x, const y = try parseMove(msg);
            board.place(tile_chars[player], x, y) catch {
                try stdout.print("Oops, that space is already occupied!\n", .{});
                continue;
            };
        }

        try stdout.print("{s}\n", .{board});
        if (board.checkForWin()) {
            try stdout.print("Congratulations Player {d}!\n", .{player + 1});
            return;
        }
        player ^= 1;
    }
}

test "Board win condition (horizontal)" {
    const b = Board{
        .tiles = [3][3]u8{
            [3]u8{ 'X', 'X', 'X' },
            [3]u8{ 32, 32, 32 },
            [3]u8{ 32, 32, 32 },
        },
    };

    try std.testing.expect(b.checkForWin());
}
test "Board win condition (vertical)" {
    const b = Board{
        .tiles = [3][3]u8{
            [3]u8{ 'X', 32, 32 },
            [3]u8{ 'X', 32, 32 },
            [3]u8{ 'X', 32, 32 },
        },
    };

    try std.testing.expect(b.checkForWin());
}

test "Board win condition (diagonal)" {
    const b = Board{
        .tiles = [3][3]u8{
            [3]u8{ 'X', 32, 32 },
            [3]u8{ 32, 'X', 32 },
            [3]u8{ 32, 32, 'X' },
        },
    };

    try std.testing.expect(b.checkForWin());
}
