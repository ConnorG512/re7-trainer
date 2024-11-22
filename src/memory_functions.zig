const std = @import("std");
const winapi = @import("winapi.zig");

const memError = error{
    outOfAllocRange,
};

// Calculates the relative offset used with the relative jmp instruction.
// This is required for jumping to and away from custom code
pub fn calculateRelativeOffset(memory_address_to: u64, memory_address_from: u64) i64 {
    const relative_offset: i64 = @bitCast(memory_address_to -% (memory_address_from + 5));

    std.log.debug("calculateRelativeOffset: relative_offset = {X}\n", .{relative_offset});
    return relative_offset;
}

// Writes custom bytes to a memory location in a looping fashion with an index to write a jump inbetween.
// ensure that this memory has been allocated, and / or read / write / execute permissions have been set.
// returns the index of the array to be used later in jumps.
// This is used for use in conditional custom code where jmp needs to be added in the middle.
// If null, will ignore the jmp index check
// if not writing a jmp mid instruction, relative_offset can be set to null.
pub fn WriteCodeToMemory(memory_location: u64, custom_bytes: []const u8) u64 {
    const ptr_memory_location: [*]u8 = @ptrFromInt(memory_location);
    var index: u8 = 0;

    for (custom_bytes) |byte| {
        ptr_memory_location[index] = byte;
        index += 1;
    }

    return memory_location + index;
}

// Calculate the relative offset from the two provided addresses to the function
// Write the result to memory to create the jump.
pub fn writeAndJump(address_to_jump_to: u64, address_to_jump_from: u64) void {
    const relative_offset: i64 = @bitCast(address_to_jump_to -% (address_to_jump_from + 5));

    // Writing the jump into memory.
    const ptr_address_to_jump_from: [*]u8 = @ptrFromInt(address_to_jump_from);
    ptr_address_to_jump_from[0] = 0xE9;
    ptr_address_to_jump_from[1] = @intCast(relative_offset & 0xFF);
    ptr_address_to_jump_from[2] = @intCast((relative_offset >> 8) & 0xFF);
    ptr_address_to_jump_from[3] = @intCast((relative_offset >> 16) & 0xFF);
    ptr_address_to_jump_from[4] = @intCast((relative_offset >> 24) & 0xFF);

    std.debug.print("writeAndJump: ptr_address_to_jump_from = {*}\n", .{ptr_address_to_jump_from});
    std.debug.print("writeAndJump: ptr_address_to_jump_to = {X}\n", .{address_to_jump_to});
    std.debug.print("writeAndJump: relative_offset = {X}\n", .{relative_offset});
}

// If a single line is required to be written over with no jumping, then use this function
pub fn singleInstructionReplace(address_to_write_to: u64, bytes_to_write: []const u8) void {
    const ptr_address_to_write_to: [*]u8 = @ptrFromInt(address_to_write_to);
    var index: u8 = 0;

    for (bytes_to_write) |byte| {
        ptr_address_to_write_to[index] = byte;

        index += 1;
    }

    std.log.debug("singleInstructionReplace: index = {*}\n", .{ptr_address_to_write_to});
    std.log.debug("singleInstructionReplace: index = {d}\n", .{index});
}

// Scans for free memory within a 32 bit integer size of the provided address.
// If memory is found, will reserve that memory and allocate a number of bytes based on the size of the custom code provided.
// Returns the pointer of the allocated memory casted as a u64 value.
pub fn VMScanAllocate(initial_memory_address: u64, jump_size: u16, allocation_byte_size: u8) memError!u64 {
    const allocation_jump_size: u32 = 2000000000;
    var virtual_alloc_result: ?winapi.LPVOID = null;
    var allocation_jump_distance: u32 = 0;

    while (virtual_alloc_result == null and allocation_jump_distance < allocation_jump_size) {
        const ptr_allocation_jump_distance: *u32 = &allocation_jump_distance;
        const address_to_scan: u64 = initial_memory_address + allocation_jump_distance;

        virtual_alloc_result = winapi.VirtualAlloc(@ptrFromInt(address_to_scan), allocation_byte_size, winapi.MEM_RESERVE, winapi.PAGE_EXECUTE_READWRITE);
        ptr_allocation_jump_distance.* += jump_size;
    }

    if (allocation_jump_distance >= allocation_jump_size) {
        std.log.err("VMScanAllocate: Could not find an address in jumping distance of allocation_jump_size! ", .{});
        return memError.outOfAllocRange;
    }

    // Once virtual_alloc_result returns true:
    std.log.debug("VMScanAllocate: Virtual Alloc success result = {?}\n", .{virtual_alloc_result});
    return @intFromPtr(winapi.VirtualAlloc(virtual_alloc_result, allocation_byte_size, winapi.MEM_COMMIT, winapi.PAGE_EXECUTE_READWRITE));
}

// Call VirtualProtect on a piece of memory and get the result, if failed call GetLastError for debugging.
pub fn byteProtection(memory_address: u64, previous_protection_value_store: ?*u32) void {
    const virtual_protect_result: winapi.BOOL = winapi.VirtualProtect(@ptrFromInt(memory_address), 4, winapi.PAGE_EXECUTE_READWRITE, previous_protection_value_store);

    if (virtual_protect_result == 0) {
        std.log.err("byteProtection: Failed! get last error = {d}\n", .{winapi.GetLastError()});
        return;
    }

    std.log.debug("byteProtection: Success! {d}", .{virtual_protect_result});
}
