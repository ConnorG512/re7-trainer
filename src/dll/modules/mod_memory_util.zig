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

pub fn calculateAndStoreRelativeOffset(memory_address_to: u64, memory_address_from: u64) []u8 {
    const relative_offset = calculateRelativeOffset(memory_address_to, memory_address_from);
    const jump_bytes = storeRelativeOffset(relative_offset);
    return jump_bytes;
}

fn calculateRelativeOffset(memory_address_to: u64, memory_address_from: u64) i64 {
    const relative_offset: i64 = @bitCast(memory_address_to -% (memory_address_from + 5));
    std.log.debug("calculateRelativeOffset: relative_offset = {X}\n", .{relative_offset});

    return relative_offset;
}

fn storeRelativeOffset(relative_offset: i64) []u8 {
    var stored_bytes: [5]u8 = [5]u8{0x1, 0x2, 0x3, 0x4, 0x5};

    stored_bytes[0] = 0xE9;
    stored_bytes[1] = @intCast(relative_offset & 0xFF);
    stored_bytes[2] = @intCast((relative_offset >> 8) & 0xFF);
    stored_bytes[3] = @intCast((relative_offset >> 16) & 0xFF);
    stored_bytes[4] = @intCast((relative_offset >> 24) & 0xFF);
    
    std.log.debug("(storeRelativeOffset) Decimal {d}.\n", .{stored_bytes});
    std.log.debug("(storeRelativeOffset) Hex {X}.\n", .{stored_bytes});
    return &stored_bytes;
}