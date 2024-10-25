const winapi = @import("winapi.zig");
const std = @import("std");

const cheatTemplate = struct {
    addressToPatch: u64,       // Pointer to a unsigned 64 bit address
    originalBytes: []const u8, // Slices of any size 
    newBytes: []const u8,      // Slices of any size
    prevProtectionValue: u32, 

    pub fn startInjection(self: cheatTemplate, baseAddress: u64) void {
        self.byteProtection(baseAddress);
    }

    fn writeBytes(_: cheatTemplate, _:u64) void {
        
    }

    fn byteProtection(self: cheatTemplate, baseAddress: u64) void {
        // Calculate the base exe address + offset to the instruction 
        const calculatedAddress = baseAddress + self.addressToPatch;

        std.debug.print("Base address: {x}\n", .{baseAddress});
        std.debug.print("Relative Instruction: {x}\n", .{self.addressToPatch});
        std.debug.print("Added together: {x}\n\n", .{calculatedAddress});

        const VirtProtResult = winapi.VirtualProtect(@ptrFromInt(calculatedAddress), 4, 0x40, @constCast(&self.prevProtectionValue));
        const GLE: winapi.DWORD = winapi.GetLastError();

        if (VirtProtResult  == 0) {
            std.debug.print("ERROR: VirtualProtect Failed!\n", .{});
            std.debug.print("ERROR: GetLastError = {d}", .{GLE});
        }
    }
};

pub var infiniteScrap = cheatTemplate {
    .addressToPatch = 0x0000000001d80664,
    .originalBytes = &[_]u8 {0x48,0x8b,0x5e,0x58},
    .newBytes = &[_]u8 {0x90,0x90,0x90,0x90},
    .prevProtectionValue = 0,
};