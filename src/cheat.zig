const winapi = @import("winapi.zig");
const std = @import("std");
const mf = @import("memory_functions.zig");

pub const CheatTemplate = struct {
    baseAddress: u64,                           // Base address for the application
    offsetToPatch: u64,                         // Pointer to a unsigned 64 bit address
    offsetToJumpBack: u64,                      // Offset to jump back to from custom code 
    virtualAllocateAddress: u64,
    virtualAllocateByteSize: winapi.SIZE_T,
    originalBytes: []const u8,                  // Slices of any size
    newBytes: []const u8,                       // Slices of any size
    prevProtectionValue: u32,
    returnDistanceFromBase: u8,

    pub fn startInjection(self: *CheatTemplate) void {
        self.*.storeBaseAddress();
        self.*.allocateVirtualMemory();
        self.*.byteProtection();
        self.*.writeBytes();
    }

    fn storeBaseAddress (self: *CheatTemplate) void {
        self.*.baseAddress = @intFromPtr(winapi.GetModuleHandleA("re7.exe"));
        std.debug.print("Base Address: {X}\n", .{self.*.baseAddress});
    }

    fn allocateVirtualMemory(self: *CheatTemplate) void {
        // We need to call the VirtualAlloc function in offsets of 4096 bytes and check to see if the memory can be allocated at that location
        // Virtual Alloc will return a base address if successful, will return NULL if failed
        // Max range of a signed 32 bit int is: -2147483648 to 2147483647

        const initial_instruction_location: u64 = self.*.baseAddress + self.*.offsetToPatch;
        var allocation_jump_distance: u64 = 4096 * 4;
        var virtual_alloc_result: ?winapi.LPCVOID = null;

        while (virtual_alloc_result == null and allocation_jump_distance < 2000000000) {
            const current_memory_location: u64 = initial_instruction_location + allocation_jump_distance;

            // Reserving the address using virtual Alloc
            virtual_alloc_result = winapi.VirtualAlloc(@ptrFromInt(current_memory_location), self.*.virtualAllocateByteSize, winapi.MEM_RESERVE,winapi.PAGE_EXECUTE_READWRITE);

            if (virtual_alloc_result != null) {
                // Run if VirtualAlloc succeeds in finding an address
                std.log.info("Virtual Alloc address created successfully at address {?}, offset from instruction by {d}/{X}\n", .{virtual_alloc_result, allocation_jump_distance, allocation_jump_distance});
                
                // Commit the memory to Virtual Alloc
                self.*.virtualAllocateAddress = @intFromPtr(winapi.VirtualAlloc(@constCast(virtual_alloc_result), self.*.virtualAllocateByteSize, winapi.MEM_COMMIT, winapi.PAGE_EXECUTE_READWRITE));
                std.log.info("Attempted commit allocation at address {?}, byte size {d}, allocation type {X}, flprotect {X}. Returned value {X}", .{virtual_alloc_result, self.*.virtualAllocateByteSize, 0x00001000, 0x40, self.*.virtualAllocateAddress});
                return;
            }

            // Adding an extra jump distance on for next loop
            const ptr_allocation_jump_distance: *u64 = &allocation_jump_distance;
            ptr_allocation_jump_distance.* += 4096 * 4; // Add with its self
            std.log.debug("Virtual Alloc Failed! Retrying at offset {d}/{X} from address {X}\n", .{allocation_jump_distance, allocation_jump_distance, current_memory_location});
            std.log.debug("Get Last Error: {d}\n\n", .{winapi.GetLastError()});
        }

        self.*.virtualAllocateAddress = @intFromPtr(winapi.VirtualAlloc(null, 15, 0x00001000, 0x40));
        std.log.info("Failed to find a suitable address for validation stored at address: {X}\n\n", .{self.*.virtualAllocateAddress});
    }

    fn byteProtection(self: *CheatTemplate) void {
        const calculatedAddress = self.*.baseAddress + self.*.offsetToPatch;
        const VirtProtResult = winapi.VirtualProtect(@ptrFromInt(calculatedAddress), 4, 0x40, @constCast(&self.*.prevProtectionValue));

        if (VirtProtResult == 0) {
            const GLE: winapi.DWORD = winapi.GetLastError();
            std.log.err("VirtualProtect Failed! {d}\n", .{VirtProtResult});
            std.log.err("GetLastError = {d}\n\n", .{GLE});
        } else {
            std.log.debug("VirtualProtect VirtProtResult: {d}\n\n", .{VirtProtResult});
        }
    }

    fn writeBytes(self: *CheatTemplate) void {
        var index: u8 = 0;
        var ptr_jump_instruction: *[5]u8 = undefined;
        var address_to_jump_to: u64 = 0x0;
        var custom_code_jump_address: u64 = 0x0;
        var relative_offset: i64 = 0x0;

        // Writing the custom code into memory.

        // Calculating the jump to the custom code
        custom_code_jump_address = self.*.baseAddress + self.offsetToPatch;
        address_to_jump_to = self.*.virtualAllocateAddress;
        relative_offset = @bitCast(address_to_jump_to - (custom_code_jump_address + 5));
        

        // Writing the jump to replace the original code
        ptr_jump_instruction = @ptrFromInt(custom_code_jump_address);
        ptr_jump_instruction[0] = 0xE9;
        ptr_jump_instruction[1] = @intCast(relative_offset & 0xFF);
        ptr_jump_instruction[2] = @intCast((relative_offset >> 8) & 0xFF);
        ptr_jump_instruction[3] = @intCast((relative_offset >> 16) & 0xFF);
        ptr_jump_instruction[4] = @intCast((relative_offset >> 24) & 0xFF);

        // Print debug
        std.log.debug("custom_code_jump_address: {X}\n", .{custom_code_jump_address});
        std.log.debug("custom_code_jump_address + 5: {X}", .{custom_code_jump_address + 5 });
        std.log.debug("address_to_jump_to: {X}\n", .{address_to_jump_to});
        std.log.debug("relative_offset: {X}", .{relative_offset});

        // This code with write the custom instruction from self.newbytes into the allocated memory space
        var ptr_custom_code: *[10]u8 = @ptrFromInt(self.*.virtualAllocateAddress);
                
        for (self.*.newBytes) |byte| {
            ptr_custom_code[index] = byte;
            index += 1;
        }
        std.log.debug("Index Count: {d}", .{index});

        // Writing the jump back to the original code
        address_to_jump_to = self.*.baseAddress + self.*.offsetToJumpBack;
        custom_code_jump_address = self.*.virtualAllocateAddress + index;
        relative_offset = @bitCast(address_to_jump_to -% (custom_code_jump_address + 5));
        
        

        ptr_jump_instruction = @ptrFromInt(custom_code_jump_address);
        ptr_jump_instruction[0] = 0xE9;
        ptr_jump_instruction[1] = @intCast(relative_offset & 0xFF);
        ptr_jump_instruction[2] = @intCast((relative_offset >> 8) & 0xFF);
        ptr_jump_instruction[3] = @intCast((relative_offset >> 16) & 0xFF);
        ptr_jump_instruction[4] = @intCast((relative_offset >> 24) & 0xFF);
        index = 0; // Resetting index after loop
        
        // Print debug
        std.log.debug("custom_code_jump_address: {X}\n", .{custom_code_jump_address});
        std.log.debug("custom_code_jump_address + 5: {X}", .{custom_code_jump_address + 5 });
        std.log.debug("address_to_jump_to: {X}\n", .{address_to_jump_to});
        std.log.debug("relative_offset: {X}", .{relative_offset});

        // Print info strings
        std.log.info("Base Address: {X}\n", .{self.*.baseAddress});
        std.log.info("Offset to patch {X}\n", .{self.*.offsetToPatch});
        std.log.info("Virtual Alloc Address {X}\n", .{self.*.virtualAllocateAddress});
    }
};

///////////////////////////////////
// INSTANCE
///////////////////////////////////
pub var infiniteScrap = CheatTemplate{
    .baseAddress = 0x0,
    .offsetToPatch = 0x0000000001d80673,
    .offsetToJumpBack = 0x1d8067a,
    .prevProtectionValue = 0x0,
    .virtualAllocateAddress = 0x0,
    .virtualAllocateByteSize = 18,
    .originalBytes = &[_]u8{0x44, 0x89, 0x7E, 0x6C},                                  // Original bytes for if the bytes need to be reverted 
    .newBytes = &[_]u8{0xC7, 0x46, 0x6C, 0x9F, 0x86, 0x01, 0x00, 0x48, 0x85, 0xDB},   // New code to modify the executable state ending with an e9 jump to add the address on the end                    
    .returnDistanceFromBase = 7,
};
