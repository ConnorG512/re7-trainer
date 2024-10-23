const std = @import("std");
const winapi = @import("winapi.zig");

pub export fn DllMain(_: ?winapi.HINSTANCE, fdwReason: winapi.DWORD, _: ?winapi.LPVOID) winapi.BOOL {
    switch (fdwReason) {
        1 => { // DLL_PROCESS_ATTACH
            _ = winapi.AllocConsole();
            std.debug.print("DLL_PROCESS_ATTACH\n", .{});
            std.debug.print("DLL Attached to the attached to the current process correctly...\n\n", .{});

            return winapi.WIN_TRUE;
        },
        2 => { // DLL_THREAD_ATTACH
            std.debug.print("DLL_THREAD_ATTACH\n", .{});
            
            return winapi.WIN_TRUE;
        },
        3 => { // DLL_THREAD_DETACH
            std.debug.print("DLL_THREAD_DETACH\n", .{});

            return winapi.WIN_TRUE;
        },
        0 => { // DLL_PROCESS_DETACH
            std.debug.print("DLL_PROCESS_DETACH\n", .{});

            return winapi.WIN_TRUE;
        },
        else => { // CATCH ALL
            return winapi.WIN_FALSE;
        }
    }

}