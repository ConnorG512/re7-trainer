const std = @import("std");
const winapi = @import("winapi.zig");
const CheatInstance = @import("cheat/cheat_instance.zig");

pub export fn DllMain(_: ?winapi.HINSTANCE, fdwReason: winapi.DWORD, _: ?winapi.LPVOID) winapi.BOOL {
    switch (fdwReason) {
        1 => { // DLL_PROCESS_ATTACH
            _ = winapi.AllocConsole();
            // X ray
            CheatInstance.x_ray.cheat_base_struct.initialiseCheat();
            CheatInstance.x_ray.writeBytesToMemory(CheatInstance.x_ray.custom_bytes);
            return winapi.WIN_TRUE;
        },
        2 => { // DLL_THREAD_ATTACH

            return winapi.WIN_TRUE;
        },
        3 => { // DLL_THREAD_DETACH

            return winapi.WIN_TRUE;
        },
        0 => { // DLL_PROCESS_DETACH

            return winapi.WIN_TRUE;
        },
        else => { // CATCH ALL
            return winapi.WIN_FALSE;
        },
    }
}