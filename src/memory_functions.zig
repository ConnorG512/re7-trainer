const std = @import("std");

// Write the jump instruction along with the offset to the specified memory address.
pub fn writeJmpToMemoryAddress(memory_address: *[5]u8, value_to_write: i64) void {
    memory_address[0] = 0xE9; // Relative jmp opcode
    memory_address[1] = @intCast(value_to_write & 0xFF);
    memory_address[2] = @intCast((value_to_write >> 8) & 0xFF);
    memory_address[3] = @intCast((value_to_write >> 16) & 0xFF);
    memory_address[4] = @intCast((value_to_write >> 24) & 0xFF);

    std.log.debug("writeJmpToMemoryAddress: memory_address = {X}\n", .{memory_address});
}

// Calculates the relative offset used with the relative jmp instruction.
// This is required for jumping to and away from custom code
pub fn calculateRelativeOffset(memory_address_to: u64, memory_address_from: u64) i64 {
    const relative_offset: i64 = @bitCast(memory_address_to -% (memory_address_from + 5));

    std.log.debug("calculateRelativeOffset: relative_offset = {X}\n", .{relative_offset});
    return relative_offset;
}

// write a portion of custom code to the specified memory address.
// ensure that this memory has been allocated, and / or read / write / execute permissions have been set.
// returns the index of the array to be used later in jumps.
pub fn writeCustomCodeToMemory(memory_address_to_write: u64, custom_bytes: []const u8) u8 {
    // Getting a pointer to the location in memory to write to.
    const ptr_to_writable_memory: [*]u8 = @ptrFromInt(memory_address_to_write);
    var index: u8 = 0;

    for (custom_bytes) |byte| {
        ptr_to_writable_memory[index] = byte;
        index += 1;
    }

    std.log.debug("writeCustomCodeToMemory: index count = {d}", .{index});
    return index;
}
