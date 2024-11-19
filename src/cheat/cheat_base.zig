const std = @import("std");
const winapi = @import("../winapi.zig");

pub const CheatBase = struct {
    cheat_name: []const u8,
    cheat_enabled: bool,
    process_base_id: ?u64,
    offset_to_patch: u64,
    vp_previous_protection: u32,

    const CheatBaseError = error{
        failed_process_id,
        memory_protection_failed,
    };

    pub fn initialiseCheat(self: *CheatBase) void {
        self.printCheatInfo();
        self.getProcessID() catch |err| {
            std.debug.print("{any}", .{err});
            std.debug.panic("ERROR: Could not get process ID.", .{});
        };
        self.changeMemoryProtection() catch |err| {
            std.debug.print("{any}", .{err});
            std.debug.panic("ERROR: Could not change memory protection.", .{});
        };
    }

    pub fn printCheatInfo(self: *CheatBase) void {
        std.debug.print("Cheat: {s}, enabled? {}\n.", .{ self.cheat_name, self.cheat_enabled });
    }

    fn getProcessID(self: *CheatBase) CheatBaseError!void {
        self.process_base_id = @intFromPtr(winapi.GetModuleHandleA("re7.exe"));
        if (self.process_base_id == null) {
            return CheatBaseError.failed_process_id;
        }
    }

    fn changeMemoryProtection(self: *CheatBase) CheatBaseError!void {
        const virtual_protect_result: c_int = winapi.VirtualProtect(@ptrFromInt(self.process_base_id.? + self.offset_to_patch), 4, winapi.PAGE_EXECUTE_READWRITE, &self.vp_previous_protection);

        if (virtual_protect_result == 0) {
            return error.memory_protection_failed;
        }
    }
};
