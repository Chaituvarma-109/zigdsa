const std = @import("std");

const Self = @This();

pub const Node = struct {
    next: ?*Node = null,
    data: i32,
};

alloc: std.mem.Allocator,
head: ?*Node = null,

pub fn init(alloc: std.mem.Allocator) Self {
    return .{ .alloc = alloc };
}

pub fn deinit(self: *Self) void {
    var curr = self.head;

    while (curr) |n| {
        const next = n.next;
        self.alloc.destroy(n);
        curr = next;
    }

    self.head = null;
}

// get length of list.
pub fn size(self: *Self) usize {
    var curr = self.head;
    var count: usize = 0;

    while (curr) |n| : ({
        curr = n.next;
        count += 1;
    }) {}

    return count;
}

// at end of list.
pub fn append(self: *Self, val: i32) !void {
    const node = try self.alloc.create(Node);
    node.* = .{ .data = val, .next = null };

    if (self.head == null) {
        self.head = node;
        return;
    }

    var curr = self.head;

    while (curr) |n| : (curr = n.next) {
        if (n.next == null) {
            n.next = node;
            return;
        }
    }
}

// at the begining of list.
pub fn prepend(self: *Self, val: i32) !void {
    const node = try self.alloc.create(Node);
    node.* = .{ .data = val, .next = self.head };

    self.head = node;
}

// at any pos in the list but not at the begining and end of list.
pub fn insertAtPos(self: *Self, pos: usize, val: i32) !void {
    const len = self.size();
    if (pos == 0) return self.prepend(val);
    if (pos >= len) return self.append(val);

    const node = try self.alloc.create(Node);
    node.* = .{ .data = val };

    var curr = self.head;
    var i: usize = 0;

    while (curr) |n| : ({
        curr = n.next;
        i += 1;
    }) {
        if (i == pos - 1) {
            node.next = n.next;
            n.next = node;
            break;
        }
    }
}

// find pos of a given value.
pub fn find(self: *Self, val: i32) ?usize {
    var curr = self.head;
    var i: usize = 0;

    while (curr) |node| : ({
        curr = node.next;
        i += 1;
    }) {
        if (node.data == val) return i;
    }

    return null;
}

// remove the given value from the list.
pub fn removeVal(self: *Self, val: i32) void {
    var curr = self.head;
    var prev: ?*Node = null;

    while (curr) |node| : ({
        prev = node;
        curr = node.next;
    }) {
        if (node.data == val) {
            if (prev) |p| {
                p.next = node.next;
            } else {
                self.head = node.next;
            }
            self.alloc.destroy(node);
            return;
        }
    }
}

// removing all occurrences of a given val in the list.
pub fn removeValAll(self: *Self, val: i32) void {
    var curr = self.head;
    var prev: ?*Node = null;

    while (curr) |node| {
        if (node.data == val) {
            const next = node.next;
            if (prev) |p| {
                p.next = next;
            } else {
                self.head = next;
            }
            self.alloc.destroy(node);
            curr = next;
        } else {
            prev = node;
            curr = node.next;
        }
    }
}
