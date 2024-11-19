const std = @import("std");
const CheatBase = @import("cheat_base.zig").CheatBase;
const winapi = @import("../winapi.zig");

pub const CheatWriter = struct {
    cheat_base_struct: CheatBase,

    custom_bytes: []const u8,

    pub fn writeBytesToMemory(self: *CheatWriter) void {
        const ptr_to_memory: [*]u8 = @ptrFromInt(self.cheat_base_struct.process_base_id.? + self.cheat_base_struct.offset_to_patch);

        var index: u8 = 0;
        for (self.custom_bytes) |byte| {
            ptr_to_memory[index] = byte;

            index += 1;
        }

        std.debug.print("SUCCESS: (writeBytesToMemory), total bytes writtedm: {d}.\n", .{index});
    }
};
