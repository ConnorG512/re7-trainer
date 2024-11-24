const std = @import("std");

pub fn writeBytesToAddress(memory_address: u64, bytes_to_write: []u8) u8 {
    const ptr_to_memory_location: [*]u8 = @ptrFromInt(memory_address);
    var index: u8 = 0;
        
    for (bytes_to_write) |byte| {
        ptr_to_memory_location[index] = byte;
        index += 1;
    }
    return index;
}

pub fn calculateAndStoreRelativeOffset(memory_address_to: u64, memory_address_from: u64, jump_bytes: []u8) void {
    const relative_offset = calculateRelativeOffset(memory_address_to, memory_address_from);

    storeRelativeOffset(relative_offset, jump_bytes);
    std.debug.print("jump_bytes_array: (calculateAndStoreRelativeOffset) {X}\n", .{jump_bytes});

}

fn calculateRelativeOffset(memory_address_to: u64, memory_address_from: u64) i64 {
    const relative_offset: i64 = @bitCast(memory_address_to -% (memory_address_from + 5));
    return relative_offset;
}

fn storeRelativeOffset(relative_offset: i64, jump_bytes: []u8) void {
    jump_bytes[0] = 0xE9;
    jump_bytes[1] = @intCast(relative_offset & 0xFF);
    jump_bytes[2] = @intCast((relative_offset >> 8) & 0xFF);
    jump_bytes[3] = @intCast((relative_offset >> 16) & 0xFF);
    jump_bytes[4] = @intCast((relative_offset >> 24) & 0xFF);

}