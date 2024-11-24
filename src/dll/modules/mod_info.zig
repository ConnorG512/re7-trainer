const std = @import("std");
const winapi = @import("../../winapi.zig");

pub const ModInfo = struct {
    cheat_title: []const u8,
    base_process_ID: ?u64,
    offset_to_patch: u64,
    cheat_enabled: bool,

    const InfoError = error {
        cannot_get_process_id,
    };

    pub fn printCheatStatus(self: *ModInfo) void {
        std.debug.print("Title: {s}\n", .{self.cheat_title});
        std.debug.print("Enabled?: {any}\n", .{self.cheat_enabled});
    }

    pub fn getProcessID(self: *ModInfo) InfoError!void {
        self.base_process_ID = @intFromPtr(winapi.GetModuleHandleA("re7.exe"));

        if (self.base_process_ID == null) {
            std.debug.print("ERROR: Cannot get process ID! {any}\n", .{error.cannot_get_process_id});
            return error.cannot_get_process_id;
        }

        std.debug.print("SUCCESS: Process found at address location 0x{X}\n", .{self.base_process_ID.?});
    }
};