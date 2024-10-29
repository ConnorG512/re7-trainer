const winapi = @import("winapi.zig");
const std = @import("std");

pub const CheatTemplate = struct {
    baseAddress: u64,           // Base address for the application
    offsetToPatch: u64,         // Pointer to a unsigned 64 bit address
    virtualAllocateAddress: u64,
    originalBytes: []const u8,  // Slices of any size
    initJmpInstruction: []const u8,
    newBytes: []const u8,       // Slices of any size
    prevProtectionValue: u32,

    pub fn startInjection(self: *CheatTemplate) void {
        self.*.storeBaseAddress();
        self.*.allocateVirtualMemory();
        self.*.byteProtection();
        self.*.writeBytes();
    }

    fn storeBaseAddress (self: *CheatTemplate) void {
        self.*.baseAddress = @intFromPtr(winapi.GetModuleHandleA("re7.exe"));
        std.debug.print("Base Address: {X}\n", .{self.*.baseAddress});
    }

    fn allocateVirtualMemory(self: *CheatTemplate) void {
        self.*.virtualAllocateAddress = @intFromPtr(winapi.VirtualAlloc(null, 20, 0x00001000, 0x40));
        std.log.debug("Virtual Memory allocated at address: {X}\n", .{self.*.virtualAllocateAddress});
    }

    fn byteProtection(self: *CheatTemplate) void {
        const calculatedAddress = self.*.baseAddress + self.*.offsetToPatch;
        const VirtProtResult = winapi.VirtualProtect(@ptrFromInt(calculatedAddress), 4, 0x40, @constCast(&self.*.prevProtectionValue));

        if (VirtProtResult == 0) {
            const GLE: winapi.DWORD = winapi.GetLastError();
            std.log.err("VirtualProtect Failed! {d}\n", .{VirtProtResult});
            std.log.err("GetLastError = {d}\n\n", .{GLE});
        } else {
            std.log.debug("VirtualProtect VirtProtResult: {d}\n\n", .{VirtProtResult});
        }
    }

    fn writeBytes(self: *CheatTemplate) void {
        // Setting the integer value as a pointer to a space in memory and then getting the 4 bytes at that memory address.
        const ptrToAddress: *[4]u8 = @ptrFromInt(self.*.baseAddress + self.*.offsetToPatch);

        std.log.info("Offset to patch = {X}\n", .{self.*.offsetToPatch});
        std.log.info("Base Address + offset = {X}\n", .{self.*.baseAddress + self.*.offsetToPatch});
        std.log.info("Combines base + offet = {X}\n\n", .{ptrToAddress});

        ptrToAddress[0] = self.*.initJmpInstruction[0];
        ptrToAddress[1] = self.*.initJmpInstruction[1];
        ptrToAddress[2] = self.*.initJmpInstruction[2];
        ptrToAddress[3] = self.*.initJmpInstruction[3];

        // Storing the bytes of memory in the VirtualAlloc Memory
        std.log.debug("Length of self.*.newBytes.len : {d}\n\n", .{self.*.newBytes.len});

        const ptrToVirtAllocMem: *[10]u8 = @ptrFromInt(self.*.virtualAllocateAddress);
        var index: usize = 0;
        for (self.*.newBytes) |byte| {
            ptrToVirtAllocMem[index] = byte;
            index += 1;
            std.log.debug("{X}", .{byte});
        }
    }
};

///////////////////////////////////
// INSTANCE
///////////////////////////////////
pub var infiniteScrap = CheatTemplate{
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001d80673,
    .virtualAllocateAddress = 0x0,
    .originalBytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C },                                // Original bytes for if the bytes need to be reverted 
    .initJmpInstruction = &[_]u8{0x44, 0x01, 0x7E, 0x6C},                             // Bytes that will replace the original code to perform the jump instruction
    .newBytes = &[_]u8{0xC7, 0x46, 0x6C, 0x9F, 0x86, 0x01, 0x00, 0x48, 0x85, 0xDB},   // New code to modify the executable state
    .prevProtectionValue = 0x0,
};
