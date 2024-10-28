const winapi = @import("winapi.zig");
const std = @import("std");

const cheatTemplate = struct {
    offsetToPatch: u64,       // Pointer to a unsigned 64 bit address
    originalBytes: []const u8, // Slices of any size 
    newBytes: []const u8,      // Slices of any size
    prevProtectionValue: u32, 

    pub fn startInjection(self: cheatTemplate, baseAddress: u64) void {
        self.byteLengnthValidation();
        self.byteProtection(baseAddress);
        self.writeBytes(baseAddress);
    }

    // Validation check to ensure that the bytes that are being exchanged are of the same length
    fn byteLengnthValidation (self: cheatTemplate) void {
        const original_bytes_num: u64 = self.originalBytes.len;
        const new_bytes_num: u64 = self.newBytes.len;

        std.debug.print("INFO: length of original bytes = {d}\n", .{original_bytes_num});
        std.debug.print("INFO: length of new bytes = {d}\n", .{new_bytes_num});

        if (new_bytes_num == original_bytes_num) {
            std.debug.print("INFO: Length Validation check passed!\n\n", .{});
        } else {
            std.debug.print("Validation check not passed! Bytes are not of the same length!\n", .{});
        }
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
            std.debug.print("ERROR: GetLastError = {d}\n\n", .{GLE});
        }
        else {
            std.debug.print("INFO: VirtualProtect VirtProtResult: {d}\n", .{VirtProtResult});
            std.debug.print("INFO: VirtualProtect prevProtectionValue: {x}\n\n", .{self.prevProtectionValue});
        }
    }

    fn writeBytes(self: cheatTemplate, baseAddress:u64) void {
        // Setting the integer value as a pointer to a space in memory and then getting the 4 bytes at that memory address.
        const ptrToAddress: *[4]u8 = @ptrFromInt(baseAddress + self.offsetToPatch);
        var ptrSlice: [4]u8 = ptrToAddress.*;
        std.debug.print("ptrSlice = {x}\n", .{ptrSlice});
        std.debug.print("ptrSlice = {p}\n\n", .{ptrSlice});

        for (self.newBytes) |index| {
            ptrSlice[index] = self.newBytes[index];
        }
    }
};

pub var infiniteScrap = cheatTemplate {
    .offsetToPatch = 0x0000000001d80673,
    .originalBytes = &[_]u8 {0x44,0x89,0x7E,0x6C},
    .newBytes = &[_]u8 {0x90,0x90,0x90,0x90},
    .prevProtectionValue = 0,
};