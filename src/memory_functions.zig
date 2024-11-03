// Write the jump instruction along with the offset to the specified memory address.

pub fn writeJmpToMemoryAddress (memoryAddress: *[5]u8, valueToWrite: i64) void {
    memoryAddress[0] = 0xE9; // Relative jmp to address
    memoryAddress[1] = @intCast(valueToWrite & 0xFF);
    memoryAddress[2] = @intCast((valueToWrite >> 8) & 0xFF);
    memoryAddress[3] = @intCast((valueToWrite >> 16) & 0xFF);
    memoryAddress[4] = @intCast((valueToWrite >> 24) & 0xFF);
}   