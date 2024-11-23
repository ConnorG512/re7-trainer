const std = @import("std");
const ModInfo = @import("../modules/mod_info.zig").ModInfo;
const ModWrite = @import("../modules/mod_write.zig").ModWrite;
const MemUtil = @import("../modules/mod_memory_util.zig");
const ModAlloc = @import("../modules/mod_allocate.zig").ModAllocate;

pub const CheatWriterJumper = struct {
    ModInfo: ModInfo,
    ModWrite: ModWrite,
    ModAlloc: ModAlloc,

    pub fn initializeCheat(self: *CheatWriterJumper) void {

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

    fn writingToAllocatedMemroy(self: *CheatWriterJumper) void {
        var jump_bytes: [5]u8 = [_]u8{0,0,0,0,0}; // Passed into calculateAndStoreRelativeOffset to prevent dangling pointer

        self.ModAlloc.scanAndAllocateAddress(self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch) catch |err| {
            std.debug.print("ERROR: Could not change memory protections. {}\n", .{err});
        };
        var index: u8 = 0;
        
        // Writing custom code to allocated memory
        index = MemUtil.writeBytesToAddress(self.ModAlloc.allocated_memory_base_address, @constCast(self.ModAlloc.custom_alloc_bytes));
        std.log.debug("Custom bytes printed {d}\n", .{index});
        
        // Jump to return
        MemUtil.calculateAndStoreRelativeOffset(self.ModInfo.base_process_ID.? + self.ModAlloc.offset_return_back_to, self.ModAlloc.allocated_memory_base_address + index, &jump_bytes);
        index += MemUtil.writeBytesToAddress(self.ModAlloc.allocated_memory_base_address + index, &jump_bytes);
    }

    fn writingJumpToAllocatedCode(self: *CheatWriterJumper) void {
        var jump_bytes: [5]u8 = [_]u8{0,0,0,0,0}; // Passed into calculateAndStoreRelativeOffset to prevent dangling pointer

        MemUtil.calculateAndStoreRelativeOffset(self.ModAlloc.allocated_memory_base_address, self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch, &jump_bytes);
        _ = MemUtil.writeBytesToAddress(self.ModInfo.base_process_ID.? + self.ModInfo.offset_to_patch, &jump_bytes);
    }
};