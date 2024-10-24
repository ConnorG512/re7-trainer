const winapi = @import("winapi.zig");

const cheatTemplate = struct {
    addressToPatch: *u64,      // Pointer to a unsigned 64 bit address
    originalBytes: []const u8, // Slices of any sice 
    newBytes: []const u8,      // Slices of any sice 

    pub fn injectCheat(_: cheatTemplate) void {
        
    }
};