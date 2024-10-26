const winapi = @import("winapi.zig");
const std = @import("std");

const cheatTemplate = struct {
    offsetToPatch: u64,       // Pointer to a unsigned 64 bit address
    originalBytes: []const u8, // Slices of any size 
    newBytes: []const u8,      // Slices of any size
    prevProtectionValue: u32, 

    pub fn startInjection(self: cheatTemplate, baseAddress: u64) void {
        self.byteProtection(baseAddress);
        writeBytes(baseAddress);
    }

    fn writeBytes(self: cheatTemplate, baseAddress:u64) void {
        const pointerToAddress: u64 = baseAddress + self.offsetToPatch;
        @memset(@as(*u64, @intFromPtr(pointerToAddress)), self.newBytes);
    }

    fn byteProtection(self: cheatTemplate, baseAddress: u64) void {
        // Calculate the base exe address + offset to the instruction 
        const calculatedAddress = baseAddress + self.offsetToPatch;

        std.debug.print("Base address: {x}\n", .{baseAddress});
        std.debug.print("Relative Offset: {x}\n", .{self.offsetToPatch});
        std.debug.print("Base address + offset: {x}\n", .{calculatedAddress});

        const VirtProtResult = winapi.VirtualProtect(@ptrFromInt(calculatedAddress), 4, 0x40, @constCast(&self.prevProtectionValue));
        
        if (VirtProtResult  == 0) {
            const GLE: winapi.DWORD = winapi.GetLastError();
            std.debug.print("ERROR: VirtualProtect Failed! {d}\n", .{VirtProtResult});
            std.debug.print("ERROR: GetLastError = {d}", .{GLE});
        }
        else {
            std.debug.print("INFO: VirtualProtect VirtProtResult: {d}\n", .{VirtProtResult});
            std.debug.print("INFO: VirtualProtect prevProtectionValue: {x}\n", .{self.prevProtectionValue});
        }
    }
};

pub var infiniteScrap = cheatTemplate {
    .offsetToPatch = 0x0000000001d80664,
    .originalBytes = &[_]u8 {0x48,0x8b,0x5e,0x58},
    .newBytes = &[_]u8 {0x90,0x90,0x90,0x90},
    .prevProtectionValue = 0,
};