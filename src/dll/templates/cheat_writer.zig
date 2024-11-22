const std = @import("std");
const ModInfo = @import("../modules/mod_info.zig").ModInfo;
const ModWrite = @import("../modules/mod_write.zig").ModWrite;
const MemUntil = @import("../modules/mod_memory_util.zig");

pub const CheatWrite = struct {
    ModInfo: ModInfo,
    ModWrite: ModWrite,

    pub fn initializeCheat(self: *CheatWrite) void {
        self.ModInfo.printCheatStatus();
        self.ModInfo.getProcessID() catch |err| {
            std.debug.print("ERROR: cannot get process ID! {}\n", .{err});
        };

        self.ModWrite.changeMemoryProtections(self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch) catch |err| {
            std.debug.print("ERROR: Could not change memory protections. {}\n", .{err});
        };

        _ = MemUntil.writeBytesToAddress(self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch, @constCast(self.ModWrite.custom_bytes));
        std.debug.print("---\n", .{});
    }   
};