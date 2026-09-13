const std = @import("std");

const Self = @This();

pub const Node = struct {
    next: ?*Node = null,
    data: i32,
};

alloc: std.mem.Allocator,
head: ?*Node = null,
tail: ?*Node = null,
len: usize = 0,

pub fn init(alloc: std.mem.Allocator) Self {
    return .{ .alloc = alloc };
}

pub fn deinit(self: *Self) void {
    var current = self.head;

    while (current) |node| {
        const next = node.next;
        self.alloc.destroy(node);
        current = next;
    }

    self.head = null;
    self.tail = null;
    self.len = 0;
}

pub fn size(self: *Self) usize {
    return self.len;
}

pub fn append(self: *Self, val: i32) void {
    const node = try self.alloc.create(Node);
    node.* = .{ .data = val };

    if (self.tail) |t| {
        t.next = node;
    } else {
        self.head = node;
    }

    self.tail = node;
    self.len += 1;
}

pub fn prepend(self: *Self, val: i32) void {
    const node = try self.alloc.create(Node);
    node.* = .{ .data = val, .next = self.head };

    self.head = node;
    if (self.tail == null) self.tail = node;

    self.len += 1;
}

pub fn search(self: *Self, val: i32) ?*Node {
    var curr = self.head;

    while (curr) |n| : (curr = n.next) {
        if (n.data == val) return n;
    }

    return null;
}

pub fn remove(self: *Self, val: i32) bool {
    if (self.head == null) return false;

    var curr = self.head;
    var previous: ?*Node = null;

    while (curr) |n| : (curr = n.next) {
        if (n.data == val) {
            if (previous) |pn| {
                pn.next = n.next;
            } else {
                self.head = n.next;
            }

            if (self.tail == n) self.tail = previous;
            self.alloc.destroy(n);
            self.len -= 1;

            return true;
        }

        previous = n;
    }

    return false;
}
