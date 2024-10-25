const winapi = @import("winapi.zig");
const std = @import("std");

const cheatTemplate = struct {
    addressToPatch: u64,      // Pointer to a unsigned 64 bit address
    originalBytes: []const u8, // Slices of any size 
    newBytes: []const u8,      // Slices of any size 
    prevProtectionValue: u32,

    pub fn writeBytes(self: cheatTemplate, baseAddress:u64) void {
        const calculatedAddress = baseAddress + self.addressToPatch;
        std.debug.print("Base address: {x}\n", .{baseAddress});
        std.debug.print("Relative Instruction: {x}\n", .{self.addressToPatch});
        std.debug.print("Added together: {x}\n\n", .{baseAddress + self.addressToPatch});

        const VirtProtResult = winapi.VirtualProtect(@ptrFromInt(calculatedAddress), 4, 0x40, null);

        if (VirtProtResult == 0) {
            std.debug.print("ERROR: VirtualProtect Failed! Result: {d}\n", .{VirtProtResult});
            const GLEResult = winapi.GetLastError();
            std.debug.print("ERROR: Get Last Error Result: {d}\n", .{GLEResult});
        }
        else {
            std.debug.print("Changed virtualProtect at address: {x}!\n", .{self.addressToPatch});
            std.debug.print("VirtualProtect Result: {d}\n", .{VirtProtResult});
        }
    }
};

pub var infiniteScrap = cheatTemplate {
    .addressToPatch = 0x0000000001d80664,
    .originalBytes = &[_]u8 {0x48,0x8b,0x5e,0x58},
    .newBytes = &[_]u8 {0x90,0x90,0x90,0x90},
    .prevProtectionValue = 0
};