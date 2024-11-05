const winapi = @import("winapi.zig");
const std = @import("std");
const mf = @import("memory_functions.zig");

pub const CheatTemplate = struct {
    cheat_title: []const u8, // Title of the cheat
    baseAddress: u64, // Base address for the application
    offsetToPatch: u64, // Pointer to a unsigned 64 bit address
    offsetToJumpBack: u64, // Offset to jump back to from custom code
    virtualAllocateAddress: u64,
    virtualAllocateByteSize: u8,
    originalBytes: []const u8, // Slices of any size
    newBytes: []const u8, // Slices of any size
    newBytes2: []const u8,
    prevProtectionValue: u32,

    pub fn printInfo(self: *CheatTemplate) void {
        std.debug.print("Cheat Title: {s}\n", .{self.*.cheat_title});
    }

    pub fn storeBaseAddress(self: *CheatTemplate) void {
        self.*.baseAddress = @intFromPtr(winapi.GetModuleHandleA("re7.exe"));
        std.debug.print("Base Address: {X}\n", .{self.*.baseAddress});
    }

    pub fn allocateVirtualMemory(self: *CheatTemplate) void {
        // Search for allocated address, if failed return catch the error and return.
        self.*.virtualAllocateAddress = mf.VMScanAllocate(self.*.baseAddress + self.*.offsetToPatch, 4096 * 4, self.*.virtualAllocateByteSize) catch |err| {
            std.log.err("allocateVirtualMemory: Failed! {}\n", .{err});
            return;
        };
    }

    pub fn byteProtection(self: *CheatTemplate) void {
        mf.byteProtection(self.*.baseAddress + self.*.offsetToPatch, &self.*.prevProtectionValue);
    }

    pub fn writeBytes(self: *CheatTemplate) void {
        var index: u8 = 0;
        var relative_offset: i64 = 0x0;

        // Writing the custom code into memory.
        // Calculating the jump to the custom code
        relative_offset = mf.calculateRelativeOffset(self.*.virtualAllocateAddress, self.*.baseAddress + self.*.offsetToPatch);
        mf.writeJmpToMemoryAddress(@ptrFromInt(self.*.baseAddress + self.offsetToPatch), relative_offset);

        // This code with write the custom instruction from self.newbytes into the allocated memory space
        index = mf.writeCustomCodeToMemory(self.*.virtualAllocateAddress, self.*.newBytes);

        // Writing the jump back to the original code
        relative_offset = mf.calculateRelativeOffset(self.*.baseAddress + self.*.offsetToJumpBack, self.*.virtualAllocateAddress + index);
        mf.writeJmpToMemoryAddress(@ptrFromInt(self.*.virtualAllocateAddress + index), relative_offset);
    }

    pub fn doubleWriteBytes(self: *CheatTemplate) void {
        var index: u8 = 0;
        var relative_offset: i64 = 0x0;

        relative_offset = mf.calculateRelativeOffset(self.*.virtualAllocateAddress, self.*.baseAddress + self.*.offsetToPatch);
        mf.writeJmpToMemoryAddress(@ptrFromInt(self.*.baseAddress + self.*.offsetToPatch), relative_offset);

        // Write the first set of bytes to the virtual alloc address. Store the index.
        index = mf.writeCustomCodeToMemory(self.*.virtualAllocateAddress, self.*.newBytes);
        relative_offset = mf.calculateRelativeOffset(self.*.baseAddress + self.*.offsetToJumpBack, self.*.virtualAllocateAddress + index);
        // Adding five to the index to cover the jmp as we need to write more bytes after.
        index + 5;
        mf.writeCustomCodeToMemory(@ptrFromInt(self.*.baseAddress + self.*.offsetToPatch + index), self.*.newBytes2);
        relative_offset = mf.calculateRelativeOffset(self.*.baseAddress + self.*.offsetToJumpBack, self.*.virtualAllocateAddress + index);
    }
};

///////////////////////////////////
// INSTANCE
///////////////////////////////////
pub var infinite_scrap = CheatTemplate{
    .cheat_title = "INFINITE SCRAP",
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001d80673,
    .offsetToJumpBack = 0x1d8067a,
    .prevProtectionValue = 0x0,
    .virtualAllocateAddress = 0x0,
    .virtualAllocateByteSize = 16,
    .originalBytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C, 0x48 }, // Original bytes for if the bytes need to be reverted
    .newBytes = &[_]u8{ 0xC7, 0x46, 0x6C, 0x9F, 0x86, 0x01, 0x00, 0x48, 0x85, 0xDB }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .newBytes2 = &[_]u8{ 0x00 } // Extra array for bytes if a jump needs to be added in between.
};

pub var infinite_ammo_clip = CheatTemplate{
    .cheat_title = "INFINITE AMMO CLIP",
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001945FF7,
    .offsetToJumpBack = 0x1945FFF,
    .prevProtectionValue = 0x0,
    .virtualAllocateAddress = 0x0,
    .virtualAllocateByteSize = 17,
    .originalBytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C, 0x48 }, // Original bytes for if the bytes need to be reverted
    .newBytes = &[_]u8{ 0x66, 0xc7, 0x43, 0x14, 0x63, 0x00, 0x48, 0x8B, 0x5C, 0x24, 0x30 }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .newBytes2 = &[_]u8{ 0x00 } // Extra array for bytes if a jump needs to be added in between.
};

pub var infinite_hp = CheatTemplate{
    .cheat_title = "INFINITE HEALTH",
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001B815EF,
    .offsetToJumpBack = 0x1B815F4,
    .prevProtectionValue = 0x0,
    .virtualAllocateAddress = 0x0,
    .virtualAllocateByteSize = 40,
    .originalBytes = &[_]u8{ 0xF3, 0x0F, 0x11, 0x52, 0x14 }, // Original bytes for if the bytes need to be reverted
    .newBytes = &[_]u8{ 0x83, 0xBA, 0xC8, 0x00, 0x00, 0x00, 0x00, 0x75, 0x0F, 0xF3, 0x0F, 0x10, 0x52, 0x10, 0xF3, 0x0F, 0x11, 0x52, 0x14 }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .newBytes2 = &[_]u8{ 0xF3, 0x0F, 0x11, 0x52, 0x14 } // Extra array for bytes if a jump needs to be added in between.
};