const winapi = @import("winapi.zig");
const std = @import("std");

pub const CheatTemplate = struct {
    baseAddress: u64,           // Base address for the application
    offsetToPatch: u64,         // Pointer to a unsigned 64 bit address
    virtualAllocateAddress: u64,
    originalBytes: []const u8,  // Slices of any size
    newBytes: []const u8,       // Slices of any size
    prevProtectionValue: u32,

    pub fn startInjection(self: *CheatTemplate) void {
        self.*.storeBaseAddress();
        self.*.allocateVirtualMemory();
        self.*.byteLengthValidation();
        self.*.byteProtection();
        self.*.writeBytes();
    }

    fn storeBaseAddress (self: *CheatTemplate) void {
        self.*.baseAddress = @intFromPtr(winapi.GetModuleHandleA("re7.exe"));
        std.debug.print("Base Address: {X}\n", .{self.*.baseAddress});
    }

    fn allocateVirtualMemory(self: *CheatTemplate) void {
        self.*.virtualAllocateAddress = @intFromPtr(winapi.VirtualAlloc(null, 20, 0x00001000, 0x40));
        std.debug.print("Virtual Memory allocated at address: {X}\n", .{self.*.virtualAllocateAddress});
    }

    // Validation check to ensure that the bytes that are being exchanged are of the same length
    fn byteLengthValidation(self: CheatTemplate) void {
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

    fn byteProtection(self: *CheatTemplate) void {
        const calculatedAddress = self.*.baseAddress + self.*.offsetToPatch;
        const VirtProtResult = winapi.VirtualProtect(@ptrFromInt(calculatedAddress), 4, 0x40, @constCast(&self.*.prevProtectionValue));

        if (VirtProtResult == 0) {
            const GLE: winapi.DWORD = winapi.GetLastError();
            std.debug.print("ERROR: VirtualProtect Failed! {d}\n", .{VirtProtResult});
            std.debug.print("ERROR: GetLastError = {d}\n\n", .{GLE});
        } else {
            std.debug.print("INFO: VirtualProtect VirtProtResult: {d}\n", .{VirtProtResult});
        }
    }

    fn writeBytes(self: *CheatTemplate) void {
        // Setting the integer value as a pointer to a space in memory and then getting the 4 bytes at that memory address.
        const ptrToAddress: *[4]u8 = @ptrFromInt(self.*.baseAddress + self.*.offsetToPatch);
        std.debug.print("{X}\n", .{ptrToAddress});
        ptrToAddress[0] = self.newBytes[0];
        ptrToAddress[1] = self.newBytes[1];
        ptrToAddress[2] = self.newBytes[2];
        ptrToAddress[3] = self.newBytes[3];

        // Storing the bytes of memory in the VirtualAlloc Memory
        const ptrToVirtAllocMem: *[4]u8 = @ptrFromInt(self.*.virtualAllocateAddress);
        ptrToVirtAllocMem[0] = self.*.newBytes[0];
        ptrToVirtAllocMem[1] = self.*.newBytes[1];
        ptrToVirtAllocMem[2] = self.*.newBytes[2];
        ptrToVirtAllocMem[3] = self.*.newBytes[3];
    }
};

///////////////////////////////////
// INSTANCE
///////////////////////////////////
pub var infiniteScrap = CheatTemplate{
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001d80673,
    .virtualAllocateAddress = 0x0,
    .originalBytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C },
    .newBytes = &[_]u8{ 0x44, 0x01, 0x7E, 0x6C },
    .prevProtectionValue = 0x0,
};
