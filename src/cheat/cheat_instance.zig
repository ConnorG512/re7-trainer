const CheatBase = @import("cheat_base.zig").CheatBase;
const CheatWriter = @import("cheat_writer.zig").CheatWriter;

pub var x_ray = CheatWriter{
    .cheat_base_struct = .{
        .cheat_name = "X-RAY",
        .cheat_enabled = true,
        .process_base_id = undefined,
        .offset_to_patch = 0xA33597,
        .vp_previous_protection = 0x0,
    },
    .custom_bytes = &[_]u8{ 0xC6, 0x82, 0x70, 0x02, 0x00, 0x00, 0x01 },
};
