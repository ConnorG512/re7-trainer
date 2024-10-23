const std = @import("std");

pub extern "kernel32" fn VirtualProtect(lpAddress: LPVOID, dwSize: SIZE_T, flNewProtect: DWORD, lpflOldProtect: *DWORD) BOOL;
pub extern "kernel32" fn AllocConsole() BOOL;

pub const DWORD = std.os.windows.DWORD;
pub const HINSTANCE = std.os.windows.HINSTANCE;
pub const LPVOID = std.os.windows.LPVOID;
pub const BOOL = std.os.windows.BOOL;
pub const SIZE_T = std.os.windows.SIZE_T;
pub const WIN_TRUE = std.os.windows.TRUE;
pub const WIN_FALSE = std.os.windows.FALSE;
