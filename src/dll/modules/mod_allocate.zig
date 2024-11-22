const std = @import("std");
const winapi = @import("../../winapi.zig");

pub const ModAllocate = struct {

    allocated_memory_base_address: u64,
    allocation_byte_size: u8,
    allocation_jump_interval_len: u16,
    custom_alloc_bytes: []const u8,
    offset_return_back_to: u64,

    const AllocationError = error {
        out_of_alloc_range,
    };

    pub fn scanAndAllocateAddress(self: *ModAllocate, initial_memory_address: u64) AllocationError!void {
        const allocation_jump_size: u32 = 0xFFFFFFF0;
        var virtual_alloc_result: ?winapi.LPVOID = null;
        var allocation_jump_distance: u32 = 0;
        var GLE: u32 = 0;

        while (virtual_alloc_result == null and allocation_jump_distance < allocation_jump_size) {
            const address_to_scan: u64 = initial_memory_address + allocation_jump_distance;
            virtual_alloc_result = winapi.VirtualAlloc(@ptrFromInt(address_to_scan), self.allocation_byte_size, winapi.MEM_RESERVE, winapi.PAGE_EXECUTE_READWRITE);

            allocation_jump_distance += self.allocation_jump_interval_len;
        }

        if (allocation_jump_distance >= allocation_jump_size) {
            std.log.err("ERROR: (scanAndAllocateAddress) could not find an address in jumping distance of allocation_jump_size!\n", .{});
            GLE = winapi.GetLastError();
            std.debug.print("ERROR: Windows GLE = {X}/{d}\n", .{GLE,GLE});
            return error.out_of_alloc_range;
        }

        virtual_alloc_result = winapi.VirtualAlloc(virtual_alloc_result, self.allocation_byte_size, winapi.MEM_COMMIT, winapi.PAGE_EXECUTE_READWRITE);
        if (virtual_alloc_result == null) {
            GLE = winapi.GetLastError();
            std.debug.print("ERROR: Windows GLE = {X}/{d}\n", .{GLE,GLE});
        }
        std.log.debug("SUCCESS: (scanAndAllocateAddress) result: 0x{any}\n", .{virtual_alloc_result});
        self.allocated_memory_base_address = @intFromPtr(virtual_alloc_result);
    }
};