const std = @import("std");
const winapi = @import("winapi.zig");
const cheat = @import("cheat.zig");

pub export fn DllMain(_: ?winapi.HINSTANCE, fdwReason: winapi.DWORD, _: ?winapi.LPVOID) winapi.BOOL {
    switch (fdwReason) {
        1 => { // DLL_PROCESS_ATTACH
            _ = winapi.AllocConsole();
            // Inject
            // infinite scrap
            std.debug.print("{s}", .{cheat.infinite_scrap.cheat_title});
            cheat.infinite_scrap.storeBaseAddress();
            cheat.infinite_scrap.allocateVirtualMemory();
            cheat.infinite_scrap.byteProtection();
            cheat.infinite_scrap.writeBytes();

            // Infinite ammo clip
            std.debug.print("{s}", .{cheat.infinite_ammo_clip.cheat_title});
            cheat.infinite_ammo_clip.storeBaseAddress();
            cheat.infinite_ammo_clip.allocateVirtualMemory();
            cheat.infinite_ammo_clip.byteProtection();
            cheat.infinite_ammo_clip.writeBytes();

            // Infinite health
            std.debug.print("{s}", .{cheat.infinite_hp.cheat_title});
            cheat.infinite_hp.storeBaseAddress();
            cheat.infinite_hp.allocateVirtualMemory();
            cheat.infinite_hp.byteProtection();
            

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
        }
    }
}

