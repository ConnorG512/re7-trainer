const std = @import("std");
const winapi = @import("../../winapi.zig");

pub const ModWrite = struct {
    custom_bytes: []const u8,
    previous_protection_value: u32,

    const ModWriteError = error {
        mem_protect_failed,
    };

    pub fn changeMemoryProtections(self: *ModWrite, memory_address: u64) ModWriteError!void {
        const virt_prot_result = winapi.VirtualProtect(@ptrFromInt(memory_address), 4, winapi.PAGE_EXECUTE_READWRITE, &self.previous_protection_value);
        if (virt_prot_result == 0) {
            std.debug.print("ERROR: Memory protection failed! {any}\n", .{error.mem_protect_failed});
            return error.mem_protect_failed;
        }
        // Success
        std.log.debug("SUCCESS: (changeMemoryProtections) virt_prot_result={X}\n", .{virt_prot_result});
        std.debug.print("Changing protections at address 0x{X}.\n", .{memory_address});
    }
};