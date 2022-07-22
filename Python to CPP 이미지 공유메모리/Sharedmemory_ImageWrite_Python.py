import cv2
import sys
import ctypes as ct
import ctypes.wintypes as wt
import msvcrt
import numpy as np
from ctypes import *
from ctypes.wintypes import *

def main(*argv):
    FILE_MAP_ALL_ACCESS = 0x000F001F
    INVALID_HANDLE_VALUE = -1
    SHMEMSIZE = 0x100
    PAGE_READWRITE = 0x04

    kernel32_dll = ct.windll.kernel32
    msvcrt_dll = ct.cdll.msvcrt  # To be avoided

    CreateFileMapping = kernel32_dll.CreateFileMappingW
    CreateFileMapping.argtypes = (wt.HANDLE, wt.LPVOID, wt.DWORD, wt.DWORD, wt.DWORD, wt.LPCWSTR)
    CreateFileMapping.restype = wt.HANDLE

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

    file_mapping_name_ptr = ct.c_wchar_p("MyFileMappingObject")
    
    path = 'camera_image47.jpg'

    with open(path,'rb') as f:
        byte_img = f.read()     #byte 단위로 데이터 저장
    uint8_img = (ct.c_ubyte*len(byte_img)).from_buffer(bytearray(byte_img)) #1D array로 만든 후 ctype byte로 저장
    
    class ImageData(Structure):
        _fields_ = [("data_size",c_double),("data",c_uint8*len(byte_img)),]

    img_smdat = ImageData()
    img_len = ct.sizeof(img_smdat)
    img_smdat.data_size = img_len
    img_smdat.data = uint8_img
    img_ptr = pointer(img_smdat)

    ##########################################################################################################################################
    mapping_handle = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, img_len, file_mapping_name_ptr)

    print("Mapping object handle: 0x{:016X}".format(mapping_handle))
    if not mapping_handle:
        print("Could not open file mapping object: {:d}".format(GetLastError()))
        raise ct.WinError()

    mapped_view_ptr = MapViewOfFile(mapping_handle, FILE_MAP_ALL_ACCESS, 0, 0, img_len)

    print("Mapped view addr: 0x{:016X}".format(mapped_view_ptr))
    if not mapped_view_ptr:
        print("Could not map view of file: {:d}".format(GetLastError()))
        CloseHandle(mapping_handle)
        raise ct.WinError()
    print("Message size ({:d} bytes)".format(img_len))
################################################################################################################################################
    memcpy(mapped_view_ptr, img_ptr, img_len)  # Comment this line

    print("Hit a key to clean all memory maps and exit...")
    msvcrt.getch()
    

    UnmapViewOfFile(mapped_view_ptr)
    CloseHandle(mapping_handle)

if __name__ == "__main__":
    print("Python {0:s} {1:d}bit on {2:s}\n".format(" ".join(item.strip() for item in sys.version.split("\n")), 64 if sys.maxsize > 0x100000000 else 32, sys.platform))
    main(*sys.argv[1:])
    print("\nDone.")