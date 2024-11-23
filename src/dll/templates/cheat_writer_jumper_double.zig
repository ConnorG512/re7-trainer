const std = @import("std");
const ModInfo = @import("../modules/mod_info.zig").ModInfo;
const ModWrite = @import("../modules/mod_write.zig").ModWrite;
const MemUtil = @import("../modules/mod_memory_util.zig");
const ModAlloc = @import("../modules/mod_allocate.zig").ModAllocate;

pub const CheatWriterJumperDouble = struct {
    ModInfo: ModInfo,
    ModWrite: ModWrite,
    ModAlloc: ModAlloc,

    second_custom_alloc_bytes: []const u8,

    pub fn initializeCheat(self: *CheatWriterJumperDouble) void {

        self.ModInfo.printCheatStatus();
        self.ModInfo.getProcessID() catch |err| {
            std.debug.print("ERROR: cannot get process ID! {}\n", .{err});
        };
        // Original Bytes
        self.ModWrite.changeMemoryProtections(self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch) catch |err| {
            std.debug.print("ERROR: Could not change memory protections. {}\n", .{err});
        };
        self.writingToAllocatedMemroy();
        self.writingJumpToAllocatedCode();
        std.debug.print("\n", .{});
    }

    fn writingToAllocatedMemroy(self: *CheatWriterJumperDouble) void {
        self.ModAlloc.scanAndAllocateAddress(self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch) catch |err| {
            std.debug.print("ERROR: Could not change memory protections. {}\n", .{err});
        };
        var index: u8 = 0;
        var jump_bytes: []u8 = undefined;

        // Writing custom code to allocated memory
        index = MemUtil.writeBytesToAddress(self.ModAlloc.allocated_memory_base_address, @constCast(self.ModAlloc.custom_alloc_bytes));
        std.log.debug("Custom bytes printed {d}\n", .{index});
        
        // Jump to return
        jump_bytes = MemUtil.calculateAndStoreRelativeOffset(self.ModInfo.base_process_ID.? + self.ModAlloc.offset_return_back_to, self.ModAlloc.allocated_memory_base_address + index);
        index += MemUtil.writeBytesToAddress(self.ModAlloc.allocated_memory_base_address + index, jump_bytes);

        // Writing second portion of custom code.
        index += MemUtil.writeBytesToAddress(self.ModAlloc.allocated_memory_base_address + index, @constCast(self.second_custom_alloc_bytes));

        jump_bytes = MemUtil.calculateAndStoreRelativeOffset(self.ModInfo.base_process_ID.? + self.ModAlloc.offset_return_back_to, self.ModAlloc.allocated_memory_base_address + index);
        index += MemUtil.writeBytesToAddress(self.ModAlloc.allocated_memory_base_address + index, jump_bytes);
    }

    fn writingJumpToAllocatedCode(self: *CheatWriterJumperDouble) void {
        const overide_original_code_bytes: []u8 = MemUtil.calculateAndStoreRelativeOffset(self.ModAlloc.allocated_memory_base_address, self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch);
        _ = MemUtil.writeBytesToAddress(self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch, overide_original_code_bytes);
    }
};