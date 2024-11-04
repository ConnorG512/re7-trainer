const std = @import("std");
const winapi = @import("winapi.zig");

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

    std.log.debug("writeCustomCodeToMemory: index count = {d}\n", .{index});
    return index;
}

// Scans for free memory within a 32 bit integer size of the provided address.
// If memory is found, will reserve that memory and allocate a number of bytes based on the size of the custom code provided.
// Returns the pointer of the allocated memory casted as a u64 value.
pub fn VMScanAllocate(initial_memory_address: u64, jump_size: u16, allocation_byte_size: u8) u64 {
    const allocation_jump_size: u32 = 2000000000;
    var virtual_alloc_result: ?winapi.LPVOID = null;
    var allocation_jump_distance: u32 = 0;

    while (virtual_alloc_result == null and allocation_jump_distance < allocation_jump_size) {
        const ptr_allocation_jump_distance: *u32 = &allocation_jump_distance;
        const address_to_scan: u64 = initial_memory_address + allocation_jump_distance;

        virtual_alloc_result = winapi.VirtualAlloc(@ptrFromInt(address_to_scan), allocation_byte_size, winapi.MEM_RESERVE, winapi.PAGE_EXECUTE_READWRITE);
        ptr_allocation_jump_distance.* += jump_size;

    }

    if (allocation_jump_distance == allocation_jump_size) {
        std.log.err("VMScanAllocate: Could not find an address in jumping distance of allocation_jump_size! ", .{});
        return;
    }

    // Once virtual_alloc_result returns true:
    std.log.debug("VMScanAllocate: Virtual Alloc success result = {?}\n", .{virtual_alloc_result});
    return @intFromPtr(winapi.VirtualAlloc(virtual_alloc_result, allocation_byte_size, winapi.MEM_COMMIT, winapi.PAGE_EXECUTE_READWRITE));
}

// Call VirtualProtect on a piece of memory and get the result, if failed call GetLastError for debugging.
pub fn byteProtection (memory_address: u64, previous_protection_value_store: ?*u32) void {
    const virtual_protect_result: winapi.BOOL = winapi.VirtualProtect(@ptrFromInt(memory_address), 4, winapi.PAGE_EXECUTE_READWRITE, previous_protection_value_store);

    if (virtual_protect_result == 0) {
        std.log.err("byteProtection: Failed! get last error = {d}\n", .{winapi.GetLastError()});
        return;
    }

    std.log.debug("byteProtection: Success! {d}", .{virtual_protect_result});
}