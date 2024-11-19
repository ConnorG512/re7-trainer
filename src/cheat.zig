const winapi = @import("winapi.zig");
const std = @import("std");
const mf = @import("memory_functions.zig");

pub const CheatTemplate = struct {
    cheat_title: []const u8, // Title of the cheat
    base_address: u64, // Base address for the application
    offset_to_patch: u64, // Pointer to a unsigned 64 bit address
    offset_to_jump_back: u64, // Offset to jump back to from custom code
    relative_offset: i64, // Calculation of a relative offset
    virtual_allocate_address: u64,
    virtual_allocate_byte_size: u8,
    original_bytes: []const u8, // Slices of any size
    new_bytes: []const u8, // Slices of any size
    new_bytes2: []const u8, // Slices of any size
    prev_protection_value: u32,

    pub fn printInfo(self: *CheatTemplate) void {
        std.debug.print("Cheat Title: {s}\n", .{self.*.cheat_title});
    }

    pub fn storeBaseAddress(self: *CheatTemplate) void {
        self.*.base_address = @intFromPtr(winapi.GetModuleHandleA("re7.exe"));
        std.debug.print("Base Address: {X}\n", .{self.*.base_address});
    }

    pub fn allocateVirtualMemory(self: *CheatTemplate) void {
        // Search for allocated address, if failed return catch the error and return.
        self.*.virtual_allocate_address = mf.VMScanAllocate(self.*.base_address + self.*.offset_to_patch, 4096 * 4, self.*.virtual_allocate_byte_size) catch |err| {
            std.log.err("allocateVirtualMemory: Failed! {}\n", .{err});
            return;
        };
    }

    pub fn byteProtection(self: *CheatTemplate) void {
        mf.byteProtection(self.*.base_address + self.*.offset_to_patch, &self.*.prev_protection_value);
    }

    pub fn writeBytes(self: *CheatTemplate) void {
        mf.writeAndJump(self.*.virtual_allocate_address, self.*.base_address + self.*.offset_to_patch);
        // Writing a jump from the custom code back to original code
        mf.writeAndJump(self.*.base_address + self.*.offset_to_jump_back, mf.WriteCodeToMemory(self.*.virtual_allocate_address, self.*.new_bytes));
    }

    // Only used when an instruction that makes use of both new_bytes and new_bytes_2 and a jump inbetween the code is required.
    pub fn doubleWriteBytes(self: *CheatTemplate) void {
        var offset_to_place_jump: u64 = 0x0;

        // Write a jump from the base offset of the instruction to the allocated address
        mf.writeAndJump(self.*.virtual_allocate_address, self.*.base_address + self.*.offset_to_patch);
        offset_to_place_jump = mf.WriteCodeToMemory(self.*.virtual_allocate_address, self.*.new_bytes);

        mf.writeAndJump(self.*.base_address + self.offset_to_jump_back, offset_to_place_jump);
        offset_to_place_jump = mf.WriteCodeToMemory(offset_to_place_jump + 5, self.*.new_bytes2);

        mf.writeAndJump(self.*.base_address + self.offset_to_jump_back, offset_to_place_jump);
    }

    pub fn singleLineWrite(self: *CheatTemplate) void {
        mf.singleInstructionReplace(self.*.base_address + self.*.offset_to_patch, self.*.new_bytes);
    }
};

///////////////////////////////////
// INSTANCE
///////////////////////////////////
pub var infinite_scrap = CheatTemplate{
    .cheat_title = "INFINITE SCRAP\n",
    .base_address = 0x0,
    .offset_to_patch = 0x0000000001d80673,
    .offset_to_jump_back = 0x1d8067a,
    .prev_protection_value = 0x0,
    .relative_offset = 0x0,
    .virtual_allocate_address = 0x0,
    .virtual_allocate_byte_size = 16,
    .original_bytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C, 0x48 }, // Original bytes for if the bytes need to be reverted
    .new_bytes = &[_]u8{ 0xC7, 0x46, 0x6C, 0x9F, 0x86, 0x01, 0x00, 0x48, 0x85, 0xDB }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .new_bytes2 = &[_]u8{0x00},
};

pub var infinite_ammo_clip = CheatTemplate{
    .cheat_title = "INFINITE AMMO CLIP\n",
    .base_address = 0x0,
    .offset_to_patch = 0x0000000001945FF7,
    .offset_to_jump_back = 0x1945FFF,
    .prev_protection_value = 0x0,
    .relative_offset = 0x0,
    .virtual_allocate_address = 0x0,
    .virtual_allocate_byte_size = 17,
    .original_bytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C, 0x48 }, // Original bytes for if the bytes need to be reverted
    .new_bytes = &[_]u8{ 0x66, 0xc7, 0x43, 0x14, 0x63, 0x00, 0x48, 0x8B, 0x5C, 0x24, 0x30 }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .new_bytes2 = &[_]u8{0x00},
};

pub var infinite_hp = CheatTemplate{
    .cheat_title = "INFINITE HEALTH\n",
    .base_address = 0x0,
    .offset_to_patch = 0x0000000001B815EF,
    .offset_to_jump_back = 0x1B815F4,
    .prev_protection_value = 0x0,
    .relative_offset = 0x0,
    .virtual_allocate_address = 0x0,
    .virtual_allocate_byte_size = 40,
    .original_bytes = &[_]u8{ 0xF3, 0x0F, 0x11, 0x52, 0x14 }, // Original bytes for if the bytes need to be reverted
    .new_bytes = &[_]u8{
        0x83, 0xBA, 0xC8, 0x00, 0x00, 0x00, 0x00, // cmp DWORD PTR [rdx + 0xc8], 0
        0x75, 0x0F, // jne 0x18
        0xF3, 0x0F, 0x10, 0x52, 0x10, // movss xmm2, DWORD PTR [rdx + 0x10]
        0xF3, 0x0F, 0x11, 0x52, 0x14, // movss DWORD PTR [rdx + 0x14], xmm2
    }, // New code to modify the executable state ending with an e9 jump to add the address on the end
    .new_bytes2 = &[_]u8{ 0xF3, 0x0F, 0x11, 0x52, 0x14 }, // movss DWORD PTR [rdx + 0x14], xmm2
};

pub var x_ray = CheatTemplate{
    .cheat_title = "X-RAY\n",
    .base_address = 0x0,
    .offset_to_patch = 0x000000000A33597,
    .offset_to_jump_back = 0x0,
    .prev_protection_value = 0x0,
    .relative_offset = 0x0,
    .virtual_allocate_address = 0x0,
    .virtual_allocate_byte_size = 0,
    .original_bytes = &[_]u8{ 0xC6, 0x82, 0x70, 0x02, 0x00, 0x00, 0x00 }, // Original bytes for if the bytes need to be reverted
    .new_bytes = &[_]u8{ 0xC6, 0x82, 0x70, 0x02, 0x00, 0x00, 0x01 }, // Bytes to replace the old bytes 1 to 1
    .new_bytes2 = &[_]u8{0x00},
};
