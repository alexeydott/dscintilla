import ctypes as c,xml.etree.ElementTree as E
import sys,struct
from pathlib import Path
k=c.WinDLL('kernel32',use_last_error=True)
k.LoadLibraryExW.argtypes=[c.c_wchar_p,c.c_void_p,c.c_uint];k.LoadLibraryExW.restype=c.c_void_p
k.FindResourceW.argtypes=[c.c_void_p,c.c_void_p,c.c_wchar_p];k.FindResourceW.restype=c.c_void_p
k.LoadResource.argtypes=[c.c_void_p,c.c_void_p];k.LoadResource.restype=c.c_void_p
k.LockResource.argtypes=[c.c_void_p];k.LockResource.restype=c.c_void_p
k.SizeofResource.argtypes=[c.c_void_p,c.c_void_p];k.SizeofResource.restype=c.c_uint
k.FreeLibrary.argtypes=[c.c_void_p]
p=Path(sys.argv[1]).resolve()
h=k.LoadLibraryExW(str(p),None,2)
assert h
r=k.FindResourceW(h,c.c_void_p(1),'OPUS');assert r,'OPUS/1 missing'
b=c.string_at(k.LockResource(k.LoadResource(h,r)),k.SizeofResource(h,r))
t=E.fromstring(b)
assert t.tag=='opus_plugin' and t.find('usb_safe').get('safe')=='yes'
assert {x.get('platform'):x.text for x in t.findall('./usb_safe/export')}=={'x86':'scintilla.dll','x64':'scintilla64.dll'}
k.FreeLibrary(h)
print('PASS: OPUS/1 manifest and both platform dependencies')
machine=struct.unpack_from('<H',p.read_bytes(),struct.unpack_from('<I',p.read_bytes(),0x3c)[0]+4)[0]
if machine==0x14c and c.sizeof(c.c_void_p)!=4:
 print('NOTE: legacy x86 call requires a 32-bit host; manifest validated')
 sys.exit(0)
d=c.CDLL(str(p))
class Info(c.Structure): _fields_=[('size',c.c_uint),('buf',c.POINTER(c.c_wchar)),('capacity',c.c_uint)]
f=d.DVP_USBSafe;f.argtypes=[c.POINTER(Info)];f.restype=c.c_int
for capacity in [0,1,2,32]:
 b=c.create_unicode_buffer('X'*40,41)
 x=Info(c.sizeof(Info),b,capacity)
 assert f(c.byref(x))
 assert b[capacity]=='X','buffer overflow'
 if capacity: assert b[capacity-1]=='\0' or '\0' in b[:capacity]
 if capacity==32: assert b.value==('scintilla64.dll' if machine==0x8664 else 'scintilla.dll')
print('PASS: legacy USB export and bounded buffers')
k.FreeLibrary(d._handle)
