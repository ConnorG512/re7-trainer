const std = @import("std");

// Extern functions

pub extern "kernel32" fn VirtualProtect(lpAddress: LPVOID, dwSize: SIZE_T, flNewProtect: DWORD, lpflOldProtect: ?*DWORD) BOOL;
// https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualprotect

pub extern "kernel32" fn AllocConsole() BOOL;

pub extern "kernel32" fn GetLastError() DWORD;
// https://learn.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror
// https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes

pub extern "kernel32" fn GetModuleHandleA(lpModuleName: LPCSTR) HMODULE;
// https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandlea


// Windows Value types
pub const DWORD = std.os.windows.DWORD;
pub const HINSTANCE = std.os.windows.HINSTANCE;
pub const LPVOID = std.os.windows.LPVOID;
pub const BOOL = std.os.windows.BOOL;
pub const SIZE_T = std.os.windows.SIZE_T;
pub const HMODULE = std.os.windows.HMODULE;
pub const LPCSTR = std.os.windows.LPCSTR;
pub const WIN_TRUE = std.os.windows.TRUE;
pub const WIN_FALSE = std.os.windows.FALSE;
