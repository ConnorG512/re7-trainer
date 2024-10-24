const winapi = @import("winapi.zig");

const cheatTemplate = struct {
    addressToPatch: *u64,      // Pointer to a unsigned 64 bit address
    originalBytes: []const u8, // Slices of any sice 
    newBytes: []const u8,      // Slices of any sice 
    prevProtectionValue: u8,

    pub fn writeBytes(self: cheatTemplate) void {
        winapi.VirtualProtect(self.addressToPatch, 4, 0x40, self.prevProtectionValue);
    }
};

pub const infiniteScrap = cheatTemplate {
    .addressToPatch = 0x141d80664,
    .originalBytes = .{0x48,0x8b,0x5e,0x58},
    .newBytes = .{0x90,0x90,0x90,0x90},
};