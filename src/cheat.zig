const winapi = @import("winapi.zig");
const std = @import("std");
const mf = @import("memory_functions.zig");

pub const CheatTemplate = struct {
    cheat_title: []const u8, // Title of the cheat
    baseAddress: u64, // Base address for the application
    offsetToPatch: u64, // Pointer to a unsigned 64 bit address
    offset_to_jump_back: u64, // Offset to jump back to from custom code
    relative_offset: i64, // Calculation of a relative offset 
    virtualAllocateAddress: u64,
    virtualAllocateByteSize: u8,
    originalBytes: []const u8, // Slices of any size
    newBytes: []const u8, // Slices of any size
    newBytes2: []const u8, // Slices of any size
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
        mf.writeAndJump(self.*.virtualAllocateAddress, self.*.baseAddress + self.*.offsetToPatch);
        // Writing a jump from the custom code back to original code
        mf.writeAndJump(self.*.baseAddress + self.*.offset_to_jump_back, mf.WriteCodeToMemory(self.*.virtualAllocateAddress, self.*.newBytes));
    }

    // Only used when an instruction that makes use of both new_bytes and new_bytes_2 and a jump inbetween the code is required.
    pub fn doubleWriteBytes(self: *CheatTemplate) void {
        var offset_to_place_jump: u64 = 0x0;

        // Write a jump from the base offset of the instruction to the allocated address    
        mf.writeAndJump(self.*.virtualAllocateAddress, self.*.baseAddress + self.*.offsetToPatch);
        offset_to_place_jump = mf.WriteCodeToMemory(self.*.virtualAllocateAddress, self.*.newBytes);

        mf.writeAndJump(self.*.baseAddress + self.offset_to_jump_back, offset_to_place_jump);
        offset_to_place_jump = mf.WriteCodeToMemory(offset_to_place_jump + 5, self.*.newBytes2);

        mf.writeAndJump(self.*.baseAddress + self.offset_to_jump_back, offset_to_place_jump);
    }

};

///////////////////////////////////
// INSTANCE
///////////////////////////////////
pub var infinite_scrap = CheatTemplate{
    .cheat_title = "INFINITE SCRAP\n",
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001d80673,
    .offset_to_jump_back =  0x1d8067a,
    .prevProtectionValue = 0x0,
    .relative_offset = 0x0,
    .virtualAllocateAddress = 0x0,
    .virtualAllocateByteSize = 16,
    .originalBytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C, 0x48 }, // Original bytes for if the bytes need to be reverted
    .newBytes = &[_]u8{ 0xC7, 0x46, 0x6C, 0x9F, 0x86, 0x01, 0x00, 0x48, 0x85, 0xDB }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .newBytes2 = &[_]u8{0x00},
};

pub var infinite_ammo_clip = CheatTemplate{
    .cheat_title = "INFINITE AMMO CLIP\n",
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001945FF7,
    .offset_to_jump_back = 0x1945FFF,
    .prevProtectionValue = 0x0,
    .relative_offset = 0x0,
    .virtualAllocateAddress = 0x0,
    .virtualAllocateByteSize = 17,
    .originalBytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C, 0x48 }, // Original bytes for if the bytes need to be reverted
    .newBytes = &[_]u8{ 0x66, 0xc7, 0x43, 0x14, 0x63, 0x00, 0x48, 0x8B, 0x5C, 0x24, 0x30 }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .newBytes2 = &[_]u8{0x00},
};

pub var infinite_hp = CheatTemplate{
    .cheat_title = "INFINITE HEALTH\n",
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001B815EF,
    .offset_to_jump_back = 0x1B815F4,
    .prevProtectionValue = 0x0,
    .relative_offset = 0x0,
    .virtualAllocateAddress = 0x0,
    .virtualAllocateByteSize = 40,
    .originalBytes = &[_]u8{ 0xF3, 0x0F, 0x11, 0x52, 0x14 },        // Original bytes for if the bytes need to be reverted
    .newBytes = &[_]u8{ 0x83, 0xBA, 0xC8, 0x00, 0x00, 0x00, 0x00,   // cmp DWORD PTR [rdx + 0xc8], 0
                                    0x75, 0x0F,                                 // jne 0x18
                                    0xF3, 0x0F, 0x10, 0x52, 0x10,               // movss xmm2, DWORD PTR [rdx + 0x10]
                                    0xF3, 0x0F, 0x11, 0x52, 0x14,               // movss DWORD PTR [rdx + 0x14], xmm2
                                    },                                          // New code to modify the executable state ending with an e9 jump to add the address on the end
    .newBytes2 = &[_]u8 {0xF3, 0x0F, 0x11, 0x52, 0x14}              // movss DWORD PTR [rdx + 0x14], xmm2
};