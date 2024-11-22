const WriterTemp = @import("templates/cheat_writer.zig").CheatWrite;
const WriterJumpTemp = @import("templates/cheat_writer_jumper.zig").CheatWriterJumper;

pub var xray = WriterTemp { 
    .ModInfo = .{
    .cheat_title = "X-RAY",
    .cheat_enabled = true,
    .offset_to_patch = 0xA33597,
    .base_process_ID = undefined,
    },
    .ModWrite = .{
        .custom_bytes = &[_]u8{ 0xC6, 0x82, 0x70, 0x02, 0x00, 0x00, 0x01 },
        .previous_protection_value = undefined,
    },
};

pub var infinite_clip = WriterJumpTemp {
    .ModInfo = .{
        .cheat_title = "INFINITE CLIP",
        .cheat_enabled = true,
        .offset_to_patch = 0x1945FF7,
        .base_process_ID = undefined,
    },
    .ModWrite = .{ 
        .custom_bytes = &[_]u8{ 0x44, 0x89, 0x7E, 0x6C, 0x48 },
        .previous_protection_value = undefined,
    },
    .ModAlloc = .{
        .custom_alloc_bytes = &[_]u8{ 0x66, 0xc7, 0x43, 0x14, 0x63, 0x00, 0x48, 0x8B, 0x5C, 0x24, 0x30 },
        .allocation_byte_size = 20,
        .allocated_memory_base_address = undefined,
        .allocation_jump_interval_len = 4096 * 4,
        .offset_return_back_to = 0x1945FFF,
    },
};