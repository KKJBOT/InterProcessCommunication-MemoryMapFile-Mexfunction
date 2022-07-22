import sys
import ctypes as ct
import ctypes.wintypes as wt
import msvcrt

from ctypes import *
from ctypes.wintypes import *

def main(*argv):
    FILE_MAP_ALL_ACCESS = 0x000F001F
    FILE_MAP_READ = 0x0004
    INVALID_HANDLE_VALUE = -1
    SHMEMSIZE = 0x100
    PAGE_READWRITE = 0x04
    FALSE = 0

    kernel32_dll = ct.windll.kernel32
    msvcrt_dll = ct.cdll.msvcrt  # To be avoided

    OpenFileMapping = kernel32_dll.OpenFileMappingW
    OpenFileMapping.argtypes = (wt.DWORD, wt.BOOL, wt.LPCWSTR)
    OpenFileMapping.restype = wt.HANDLE

    MapViewOfFile = kernel32_dll.MapViewOfFile
    MapViewOfFile.argtypes = (wt.HANDLE, wt.DWORD, wt.DWORD, wt.DWORD, ct.c_ulonglong)
    MapViewOfFile.restype = wt.LPVOID

    memcpy = msvcrt_dll.memcpy
    memcpy.argtypes = (ct.c_void_p, ct.c_void_p, ct.c_size_t)
    memcpy.restype = wt.LPVOID

    RtlCopyMemory = kernel32_dll.RtlCopyMemory
    RtlCopyMemory.argtypes = (wt.LPVOID, wt.LPCVOID, ct.c_ulonglong)

    UnmapViewOfFile = kernel32_dll.UnmapViewOfFile
    UnmapViewOfFile.argtypes = (wt.LPCVOID,)
    UnmapViewOfFile.restype = wt.BOOL

    CloseHandle = kernel32_dll.CloseHandle
    CloseHandle.argtypes = (wt.HANDLE,)
    CloseHandle.restype = wt.BOOL

    GetLastError = kernel32_dll.GetLastError

    ######################################################################################################################

    class TEST_DATA(ct.Structure):      # 파이썬용 C 구조체
        _fields_=[("data_1",ct.c_double),("data_2",ct.c_double)]

    test_smdat = TEST_DATA()            # 구조체형 변수 선언

    file_mapping_name_ptr = ct.c_wchar_p("test data")
    msg_ptr = pointer(test_smdat)       # msg_ptr = (TEST_DATA*) test_smdat
    byte_len = ct.sizeof(TEST_DATA)
##########################################################################################################################################
    mapping_handle = OpenFileMapping(FILE_MAP_READ, FALSE, file_mapping_name_ptr)

    print("Mapping object handle: 0x{:016X}".format(mapping_handle))
    if not mapping_handle:
        print("Could not open file mapping object: {:d}".format(GetLastError()))
        raise ct.WinError()

    mapped_view_ptr = MapViewOfFile(mapping_handle, FILE_MAP_READ, 0, 0, byte_len)

    print("Mapped view addr: 0x{:016X}".format(mapped_view_ptr))
    if not mapped_view_ptr:
        print("Could not map view of file: {:d}".format(GetLastError()))
        CloseHandle(mapping_handle)
        raise ct.WinError()
    print("Message size ({:d} bytes)".format(byte_len))
############################################################################################################################################

    memcpy(msg_ptr,mapped_view_ptr,byte_len)
    print(test_smdat.data_1)
    print(test_smdat.data_2)

    print("Hit a key to clean all memory maps and exit...")
    msvcrt.getch()

    UnmapViewOfFile(mapped_view_ptr)
    CloseHandle(mapping_handle)

if __name__ == "__main__":
    print("Python {0:s} {1:d}bit on {2:s}\n".format(" ".join(item.strip() for item in sys.version.split("\n")), 64 if sys.maxsize > 0x100000000 else 32, sys.platform))
    main(*sys.argv[1:])
    print("\nDone.")