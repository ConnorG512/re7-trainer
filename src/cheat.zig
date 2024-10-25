const winapi = @import("winapi.zig");

const cheatTemplate = struct {
    addressToPatch: u64,      // Pointer to a unsigned 64 bit address
    originalBytes: []const u8, // Slices of any size 
    newBytes: []const u8,      // Slices of any size 
    prevProtectionValue: u32,

    pub fn writeBytes(self: cheatTemplate) void {
        var oldProtect: u32 = 0;
        winapi.VirtualProtect(@ptrCast(&self.addressToPatch) , 4, 0x40, &oldProtect);
        self.prevProtectionValue = oldProtect;
    }
};

pub var infiniteScrap = cheatTemplate {
    .addressToPatch = 0x0000000141d80664,
    .originalBytes = &[_]u8 {0x48,0x8b,0x5e,0x58},
    .newBytes = &[_]u8 {0x90,0x90,0x90,0x90},
    .prevProtectionValue = 0
};