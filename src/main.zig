const std = @import("std");

extern "kernel32" fn AllocConsole() BOOL;

const DWORD = std.os.windows.DWORD;
const HINSTANCE = std.os.windows.HINSTANCE;
const LPVOID = std.os.windows.LPVOID;
const BOOL = std.os.windows.BOOL;
const WIN_TRUE = std.os.windows.TRUE;
const WIN_FALSE = std.os.windows.FALSE;

pub export fn DllMain(_: ?HINSTANCE, fdwReason: DWORD, _: ?LPVOID) BOOL {
    switch (fdwReason) {
        1 => { // DLL_PROCESS_ATTACH
            _ = AllocConsole();
            std.debug.print("DLL_PROCESS_ATTACH\n", .{});
            std.debug.print("DLL Attached to the attached to the current process correctly...\n\n", .{});

            return WIN_TRUE;
        },
        2 => { // DLL_THREAD_ATTACH
            std.debug.print("DLL_THREAD_ATTACH\n", .{});
            

            return WIN_TRUE;
        },
        3 => { // DLL_THREAD_DETACH
            std.debug.print("DLL_THREAD_DETACH\n", .{});

            return WIN_TRUE;
        },
        0 => { // DLL_PROCESS_DETACH
            std.debug.print("DLL_PROCESS_DETACH\n", .{});

            return WIN_TRUE;
        },
        else => { // CATCH ALL
            return WIN_FALSE;
        }
    }

}