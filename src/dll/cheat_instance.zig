const WriterTemp = @import("templates/cheat_writer.zig").CheatWrite;
const WriterJumpTemp = @import("templates/cheat_writer_jumper.zig").CheatWriterJumper;
const WriterJumpDoubleTemp = @import("templates/cheat_writer_jumper_double.zig").CheatWriterJumperDouble;

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
        .custom_bytes = undefined,
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

pub var infinite_scrap = WriterJumpTemp {
    .ModInfo = .{
        .cheat_title = "INFINITE SCRAP",
        .cheat_enabled = true,
        .offset_to_patch = 0x1D80673,
        .base_process_ID = undefined,
    },
    .ModWrite = .{ 
        .custom_bytes = undefined,
        .previous_protection_value = undefined,
    },
    .ModAlloc = .{
        .custom_alloc_bytes = &[_]u8{ 0xC7, 0x46, 0x6C, 0x9F, 0x86, 0x01, 0x00, 0x48, 0x85, 0xDB },
        .allocation_byte_size = 20,
        .allocated_memory_base_address = undefined,
        .allocation_jump_interval_len = 4096 * 4,
        .offset_return_back_to = 0x1D8067A,
    },
};

pub var infinite_health = WriterJumpDoubleTemp {
    .ModInfo = .{
        .cheat_title = "INFINITE HEALTH",
        .cheat_enabled = true,
        .offset_to_patch = 0x1B815EF,
        .base_process_ID = undefined,
    },
    .ModWrite = .{ 
        .custom_bytes = undefined,
        .previous_protection_value = undefined,
    },
    .ModAlloc = .{
        .custom_alloc_bytes = &[_]u8{
        0x83, 0xBA, 0xC8, 0x00, 0x00, 0x00, 0x00, // cmp DWORD PTR [rdx + 0xc8], 0
        0x75, 0x0F, // jne 0x18
        0xF3, 0x0F, 0x10, 0x52, 0x10, // movss xmm2, DWORD PTR [rdx + 0x10]
        0xF3, 0x0F, 0x11, 0x52, 0x14, // movss DWORD PTR [rdx + 0x14], xmm2
        }, // New code to modify the executable state ending with an e9 jump to add the address on the end

        .allocation_byte_size = 40,
        .allocated_memory_base_address = undefined,
        .allocation_jump_interval_len = 4096 * 4,
        .offset_return_back_to = 0x1B815F4,
    },
    .second_custom_alloc_bytes = &[_]u8{ 0xF3, 0x0F, 0x11, 0x52, 0x14 }, // movss DWORD PTR [rdx + 0x14], xmm2
};