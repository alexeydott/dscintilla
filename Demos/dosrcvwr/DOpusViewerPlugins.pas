unit DOpusViewerPlugins;

interface

{$MINENUMSIZE 4}

uses
  Winapi.ActiveX,  Winapi.Messages,  Winapi.Windows;
	
const
  VIEWERPLUGINVERSION = 4;

  DVPFIF_CanHandleStreams = DWORD(1) shl 0;
  DVPFIF_CanHandleBytes = DWORD(1) shl 1;
  DVPFIF_CatchAll = DWORD(1) shl 2;
  DVPFIF_DefaultCatchAll = DWORD(1) shl 3;
  DVPFIF_ExtensionsOnly = DWORD(1) shl 4;
  DVPFIF_ExtensionsOnlyIfSlow = DWORD(1) shl 5;
  DVPFIF_ExtensionsOnlyIfNoRndSeek = DWORD(1) shl 6;
  DVPFIF_ExtensionsOnlyForThumbnails = DWORD(1) shl 7;
  DVPFIF_NoSlowFiles = DWORD(1) shl 8;
  DVPFIF_NeedRandomSeek = DWORD(1) shl 9;
  DVPFIF_CanConfigure = DWORD(1) shl 10;
  DVPFIF_CanShowAbout = DWORD(1) shl 11;
  DVPFIF_NoThumbnails = DWORD(1) shl 12;
  DVPFIF_NoProperties = DWORD(1) shl 13;
  DVPFIF_ZeroBytesOk = DWORD(1) shl 14;
  DVPFIF_OverrideInternal = DWORD(1) shl 15;
  DVPFIF_InitialDisable = DWORD(1) shl 16;
  DVPFIF_NoFileInformation = DWORD(1) shl 17;
  DVPFIF_ProvideFileInfo = DWORD(1) shl 18;
  DVPFIF_NoMultithreadThumbnails = DWORD(1) shl 19;
  DVPFIF_FolderThumbnails = DWORD(1) shl 20;
  DVPFIF_TrueThumbnailSize = DWORD(1) shl 21;
  DVPFIF_UseVersionResource = DWORD(1) shl 22;
  DVPFIF_CanShowHex = DWORD(1) shl 23;
  DVPFIF_OnlyThumbnails = DWORD(1) shl 24;

  VPINITF_FIRSTTIME = DWORD(1) shl 0;
  VPINITF_USB = DWORD(1) shl 1;

  DVPFI_CanReturnBitmap = DWORD(1) shl 0;
  DVPFI_CanReturnViewer = DWORD(1) shl 1;
  DVPFI_CanReturnThumbnail = DWORD(1) shl 2;
  DVPFI_CanShowProperties = DWORD(1) shl 3;
  DVPFI_ResolutionInch = DWORD(1) shl 4;
  DVPFI_ResolutionCM = DWORD(1) shl 5;
  DVPFI_WantFileInfo = DWORD(1) shl 6;
  DVPFI_ReturnsText = DWORD(1) shl 7;
  DVPFI_HasAlphaChannel = DWORD(1) shl 8;
  DVPFI_HasTransparentColor = DWORD(1) shl 9;
  DVPFI_HasTransparentPen = DWORD(1) shl 10;
  DVPFI_CanReturnFileInfo = DWORD(1) shl 11;
  DVPFI_NoThumbnailBorder = DWORD(1) shl 12;
  DVPFI_NoShowThumbnailIcon = DWORD(1) shl 13;
  DVPFI_ShowThumbnailIcon = DWORD(1) shl 14;
  DVPFI_FolderThumbnail = DWORD(1) shl 15;
  DVPFI_RegenerateOnResize = DWORD(1) shl 16;
  DVPFI_JPEGStream = DWORD(1) shl 17;
  DVPFI_PNGStream = DWORD(1) shl 18;
  DVPFI_InFolderThumbnail = DWORD(1) shl 19;

  // These values mirror RTL_SIZEOF_THROUGH_FIELD(...) in the original C header on Win64.
  VIEWERPLUGININFOW_V1_SIZE = 132;
  VIEWERPLUGININFOA_V1_SIZE = 132;
  VIEWERPLUGININFOW_V4_SIZE = 144;
  VIEWERPLUGININFOA_V4_SIZE = 144;

  DVPLUGINMSG_BASE = WM_APP + $0F00;
  DVPLUGINMSG_LOADA = DVPLUGINMSG_BASE + 1;
  DVPLUGINMSG_LOADW = DVPLUGINMSG_BASE + 2;
  DVPLUGINMSG_LOADSTREAMA = DVPLUGINMSG_BASE + 3;
  DVPLUGINMSG_LOADSTREAMW = DVPLUGINMSG_BASE + 4;
  DVPLUGINMSG_GETIMAGEINFOA = DVPLUGINMSG_BASE + 5;
  DVPLUGINMSG_GETIMAGEINFOW = DVPLUGINMSG_BASE + 6;
  DVPLUGINMSG_GETCAPABILITIES = DVPLUGINMSG_BASE + 7;
  DVPLUGINMSG_RESIZE = DVPLUGINMSG_BASE + 8;
  DVPLUGINMSG_SETROTATION = DVPLUGINMSG_BASE + 9;
  DVPLUGINMSG_ROTATE = DVPLUGINMSG_BASE + 10;
  DVPLUGINMSG_SETZOOM = DVPLUGINMSG_BASE + 11;
  DVPLUGINMSG_ZOOM = DVPLUGINMSG_BASE + 12;
  DVPLUGINMSG_GETZOOMFACTOR = DVPLUGINMSG_BASE + 13;
  DVPLUGINMSG_SELECTALL = DVPLUGINMSG_BASE + 14;
  DVPLUGINMSG_TESTSELECTION = DVPLUGINMSG_BASE + 15;
  DVPLUGINMSG_COPYSELECTION = DVPLUGINMSG_BASE + 16;
  DVPLUGINMSG_PRINT = DVPLUGINMSG_BASE + 17;
  DVPLUGINMSG_PROPERTIES = DVPLUGINMSG_BASE + 18;
  DVPLUGINMSG_REDRAW = DVPLUGINMSG_BASE + 19;
  DVPLUGINMSG_GETPICSIZE = DVPLUGINMSG_BASE + 20;
  DVPLUGINMSG_GETAUTOBGCOL = DVPLUGINMSG_BASE + 21;
  DVPLUGINMSG_MOUSEWHEEL = DVPLUGINMSG_BASE + 22;
  DVPLUGINMSG_ADDCONTEXTMENUA = DVPLUGINMSG_BASE + 23;
  DVPLUGINMSG_ADDCONTEXTMENUW = DVPLUGINMSG_BASE + 24;
  DVPLUGINMSG_SETABORTEVENT = DVPLUGINMSG_BASE + 25;
  DVPLUGINMSG_GETORIGINALPICSIZE = DVPLUGINMSG_BASE + 26;
  DVPLUGINMSG_CLEAR = DVPLUGINMSG_BASE + 27;
  DVPLUGINMSG_NOTIFY_LOADPROGRESS = DVPLUGINMSG_BASE + 28;
  DVPLUGINMSG_ISDLGMESSAGE = DVPLUGINMSG_BASE + 29;
  DVPLUGINMSG_TRANSLATEACCEL = DVPLUGINMSG_BASE + 30;
  DVPLUGINMSG_REINITIALIZE = DVPLUGINMSG_BASE + 31;
  DVPLUGINMSG_SHOWHIDESCROLLBARS = DVPLUGINMSG_BASE + 32;
  DVPLUGINMSG_INLOADLOOP = DVPLUGINMSG_BASE + 33;
  DVPLUGINMSG_SETIMAGEFRAME = DVPLUGINMSG_BASE + 34;
  DVPLUGINMSG_SETDESKWALLPAPERA = DVPLUGINMSG_BASE + 35;
  DVPLUGINMSG_GETZOOMLIMITS = DVPLUGINMSG_BASE + 36;
  DVPLUGINMSG_THUMBSCHANGED = DVPLUGINMSG_BASE + 37;
  DVPLUGINMSG_GETBITMAP = DVPLUGINMSG_BASE + 38;
  DVPLUGINMSG_GAMMACHANGE = DVPLUGINMSG_BASE + 39;
  DVPLUGINMSG_APPCOMMAND = DVPLUGINMSG_BASE + 40;
  DVPLUGINMSG_PREVENTFRAME = DVPLUGINMSG_BASE + 41;
  DVPLUGINMSG_FULLSCREEN = DVPLUGINMSG_BASE + 42;
  DVPLUGINMSG_SHOWFILEINFO = DVPLUGINMSG_BASE + 43;
  DVPLUGINMSG_ISFILEINFOSHOWN = DVPLUGINMSG_BASE + 44;
  DVPLUGINMSG_SETDESKWALLPAPERW = DVPLUGINMSG_BASE + 45;
  DVPLUGINMSG_PREVENTAUTOSIZE = DVPLUGINMSG_BASE + 46;
  DVPLUGINMSG_SHOWHEX = DVPLUGINMSG_BASE + 47;
  DVPLUGINMSG_ISALPHAHIDDEN = DVPLUGINMSG_BASE + 48;
  DVPLUGINMSG_HIDEALPHA = DVPLUGINMSG_BASE + 49;
  DVPLUGINMSG_LOAD = DVPLUGINMSG_LOADW;
  DVPLUGINMSG_LOADSTREAM = DVPLUGINMSG_LOADSTREAMW;
  DVPLUGINMSG_GETIMAGEINFO = DVPLUGINMSG_GETIMAGEINFOW;
  DVPLUGINMSG_ADDCONTEXTMENU = DVPLUGINMSG_ADDCONTEXTMENUW;
  DVPLUGINMSG_SETDESKWALLPAPER = DVPLUGINMSG_SETDESKWALLPAPERW;

  DVPN_FIRST = DWORD($FFFFF830);
  DVPN_LAST = DWORD($FFFFF81C);
  DVPN_GETBGCOL = DVPN_FIRST - 0;
  DVPN_SIZECHANGE = DVPN_FIRST - 1;
  DVPN_CLICK = DVPN_FIRST - 2;
  DVPN_RESETZOOM = DVPN_FIRST - 3;
  DVPN_LBUTTONSCROLL = DVPN_FIRST - 4;
  DVPN_CLEARED = DVPN_FIRST - 5;
  DVPN_FOCUSCHANGE = DVPN_FIRST - 6;
  DVPN_CAPABILITIES = DVPN_FIRST - 7;
  DVPN_STATUSTEXT = DVPN_FIRST - 8;
  DVPN_LOADNEWFILE = DVPN_FIRST - 9;
  DVPN_SETCURSOR = DVPN_FIRST - 10;
  DVPN_MCLICK = DVPN_FIRST - 11;
  DVPN_GETGAMMA = DVPN_FIRST - 12;
  DVPN_BUTTONOPTS = DVPN_FIRST - 13;
  DVPN_GETCURSORS = DVPN_FIRST - 14;
  DVPN_MOUSEWHEEL = DVPN_FIRST - 15;
  DVPN_HEXSTATE = DVPN_FIRST - 16;

  BUTTONOPT_NONE = 0;
  BUTTONOPT_SELECT = 1;
  BUTTONOPT_ADVANCE = 2;
  BUTTONOPT_SCROLL = 3;
  BUTTONOPT_FULLSCREEN = 4;
  BUTTONOPT_CLOSE = 5;

  ZOOM_ORIGINAL = 0;
  ZOOM_FITPAGE = -1;
  ZOOM_TILED = -2;

  VPCURSOR_NONE = 0;
  VPCURSOR_DRAG = 1;
  VPCURSOR_SELECT = 2;

  VPCAPABILITY_RESIZE_FIT = DWORD(1) shl 0;
  VPCAPABILITY_RESIZE_ANY = DWORD(1) shl 1;
  VPCAPABILITY_ROTATE_RIGHTANGLE = DWORD(1) shl 2;
  VPCAPABILITY_ROTATE_ANY = DWORD(1) shl 3;
  VPCAPABILITY_SELECTALL = DWORD(1) shl 4;
  VPCAPABILITY_COPYALL = DWORD(1) shl 5;
  VPCAPABILITY_COPYSELECTION = DWORD(1) shl 6;
  VPCAPABILITY_PRINT = DWORD(1) shl 7;
  VPCAPABILITY_WANTFOCUS = DWORD(1) shl 8;
  VPCAPABILITY_SHOWPROPERTIES = DWORD(1) shl 9;
  VPCAPABILITY_WANTMOUSEWHEEL = DWORD(1) shl 10;
  VPCAPABILITY_ADDCONTEXTMENU = DWORD(1) shl 11;
  VPCAPABILITY_HASDIALOGS = DWORD(1) shl 12;
  VPCAPABILITY_HASACCELERATORS = DWORD(1) shl 13;
  VPCAPABILITY_CANSETWALLPAPER = DWORD(1) shl 14;
  VPCAPABILITY_CANTRACKFOCUS = DWORD(1) shl 15;
  VPCAPABILITY_SUPPLYBITMAP = DWORD(1) shl 16;
  VPCAPABILITY_GAMMA = DWORD(1) shl 17;
  VPCAPABILITY_FILEINFO = DWORD(1) shl 18;
  VPCAPABILITY_RESIZE_TILE = DWORD(1) shl 19;
  VPCAPABILITY_HIDEALPHA = DWORD(1) shl 20;
  VPCAPABILITY_NOFULLSCREEN = DWORD(1) shl 21;

  DVPTCF_REDRAW = DWORD(1) shl 0;
  DVPTCF_FLUSHCACHE = DWORD(1) shl 1;

  DVPCMF_CHECKED = DWORD(1) shl 0;
  DVPCMF_RADIOCHECK = DWORD(1) shl 1;
  DVPCMF_DISABLED = DWORD(1) shl 2;
  DVPCMF_SEPARATOR = DWORD(1) shl 3;
  DVPCMF_BEGINSUBMENU = DWORD(1) shl 4;
  DVPCMF_ENDSUBMENU = DWORD(1) shl 5;

  DVPFUNCNAME_INIT = 'DVP_Init';
  DVPFUNCNAME_INITEX = 'DVP_InitEx';
  DVPFUNCNAME_USBSAFE = 'DVP_USBSafe';
  DVPFUNCNAME_UNINIT = 'DVP_Uninit';
  DVPFUNCNAME_IDENTIFYA = 'DVP_IdentifyA';
  DVPFUNCNAME_IDENTIFYW = 'DVP_IdentifyW';
  DVPFUNCNAME_IDENTIFYFILEA = 'DVP_IdentifyFileA';
  DVPFUNCNAME_IDENTIFYFILEW = 'DVP_IdentifyFileW';
  DVPFUNCNAME_IDENTIFYFILESTREAMA = 'DVP_IdentifyFileStreamA';
  DVPFUNCNAME_IDENTIFYFILESTREAMW = 'DVP_IdentifyFileStreamW';
  DVPFUNCNAME_IDENTIFYFILEBYTESA = 'DVP_IdentifyFileBytesA';
  DVPFUNCNAME_IDENTIFYFILEBYTESW = 'DVP_IdentifyFileBytesW';
  DVPFUNCNAME_LOADBITMAPA = 'DVP_LoadBitmapA';
  DVPFUNCNAME_LOADBITMAPW = 'DVP_LoadBitmapW';
  DVPFUNCNAME_LOADBITMAPSTREAMA = 'DVP_LoadBitmapStreamA';
  DVPFUNCNAME_LOADBITMAPSTREAMW = 'DVP_LoadBitmapStreamW';
  DVPFUNCNAME_LOADTEXTA = 'DVP_LoadTextA';
  DVPFUNCNAME_LOADTEXTW = 'DVP_LoadTextW';
  DVPFUNCNAME_SHOWPROPERTIESA = 'DVP_ShowPropertiesA';
  DVPFUNCNAME_SHOWPROPERTIESW = 'DVP_ShowPropertiesW';
  DVPFUNCNAME_SHOWPROPERTIESSTREAMA = 'DVP_ShowPropertiesStreamA';
  DVPFUNCNAME_SHOWPROPERTIESSTREAMW = 'DVP_ShowPropertiesStreamW';
  DVPFUNCNAME_CREATEVIEWER = 'DVP_CreateViewer';
  DVPFUNCNAME_CONFIGURE = 'DVP_Configure';
  DVPFUNCNAME_ABOUT = 'DVP_About';
  DVPFUNCNAME_GETFILEINFOFILEA = 'DVP_GetFileInfoFileA';
  DVPFUNCNAME_GETFILEINFOFILEW = 'DVP_GetFileInfoFileW';
  DVPFUNCNAME_GETFILEINFOFILESTREAMA = 'DVP_GetFileInfoFileStreamA';
  DVPFUNCNAME_GETFILEINFOFILESTREAMW = 'DVP_GetFileInfoFileStreamW';
  DVPFUNCNAME_IDENTIFY = DVPFUNCNAME_IDENTIFYW;
  DVPFUNCNAME_IDENTIFYFILE = DVPFUNCNAME_IDENTIFYFILEW;
  DVPFUNCNAME_IDENTIFYFILESTREAM = DVPFUNCNAME_IDENTIFYFILESTREAMW;
  DVPFUNCNAME_IDENTIFYFILEBYTES = DVPFUNCNAME_IDENTIFYFILEBYTESW;
  DVPFUNCNAME_LOADBITMAP = DVPFUNCNAME_LOADBITMAPW;
  DVPFUNCNAME_LOADBITMAPSTREAM = DVPFUNCNAME_LOADBITMAPSTREAMW;
  DVPFUNCNAME_LOADTEXT = DVPFUNCNAME_LOADTEXTW;
  DVPFUNCNAME_SHOWPROPERTIES = DVPFUNCNAME_SHOWPROPERTIESW;
  DVPFUNCNAME_SHOWPROPERTIESSTREAM = DVPFUNCNAME_SHOWPROPERTIESSTREAMW;
  DVPFUNCNAME_GETFILEINFOFILE = DVPFUNCNAME_GETFILEINFOFILEW;
  DVPFUNCNAME_GETFILEINFOFILESTREAM = DVPFUNCNAME_GETFILEINFOFILESTREAMW;

  DVPSF_Slow = DWORD(1) shl 0;
  DVPSF_NoRandomSeek = DWORD(1) shl 1;

  DVPCVF_Border = DWORD(1) shl 1;
  DVPCVF_Preview = DWORD(1) shl 2;
  DVPCVF_ReturnTabs = DWORD(1) shl 3;
  DVPLTF_FromStream = DWORD(1) shl 0;

  DVPMusicFlag_VBR = DWORD(1) shl 0;
  DVPMusicFlag_VBRAccurate = DWORD(1) shl 1;
  DVPMusicFlag_JointStereo = DWORD(1) shl 2;

  OPUSVIEWER_IMAGE_FRAME_SIZE = 14;

type
  DOpusViewerPluginFileType = (
    DVPMajorType_Image,
    DVPMajorType_Sound,
    DVPMajorType_Text,
    DVPMajorType_Other,
    DVPMajorType_Movie
  );

  DVPFileInfoTypeHint = (
    DVPFITypeHint_None,
    DVPFITypeHint_PlainText,
    DVPFITypeHint_RichText,
    DVPFITypeHint_HTML
  );

  DVPColorSpace = (
    DVPColorSpace_Unknown,
    DVPColorSpace_Grayscale,
    DVPColorSpace_RGB,
    DVPColorSpace_YCBCR,
    DVPColorSpace_CMYK,
    DVPColorSpace_YCCK
  );

  DVPTextType = (
    DVPText_Plain,
    DVPText_Rich,
    DVPText_HTML
  );

  TVIEWERPLUGININFOWV1 = record
    cbSize: UINT;
    dwFlags: DWORD;
    dwVersionHigh: DWORD;
    dwVersionLow: DWORD;
    lpszHandleExts: LPWSTR;
    lpszName: LPWSTR;
    lpszDescription: LPWSTR;
    lpszCopyright: LPWSTR;
    lpszURL: LPWSTR;
    cchHandleExtsMax: UINT;
    cchNameMax: UINT;
    cchDescriptionMax: UINT;
    cchCopyrightMax: UINT;
    cchURLMax: UINT;
    dwlMinFileSize: DWORDLONG;
    dwlMaxFileSize: DWORDLONG;
    dwlMinPreviewFileSize: DWORDLONG;
    dwlMaxPreviewFileSize: DWORDLONG;
    uiMajorFileType: UINT;
    idPlugin: TGUID;
  end;

  TVIEWERPLUGININFOWV4 = record
    cbSize: UINT;
    dwFlags: DWORD;
    dwVersionHigh: DWORD;
    dwVersionLow: DWORD;
    lpszHandleExts: LPWSTR;
    lpszName: LPWSTR;
    lpszDescription: LPWSTR;
    lpszCopyright: LPWSTR;
    lpszURL: LPWSTR;
    cchHandleExtsMax: UINT;
    cchNameMax: UINT;
    cchDescriptionMax: UINT;
    cchCopyrightMax: UINT;
    cchURLMax: UINT;
    dwlMinFileSize: DWORDLONG;
    dwlMaxFileSize: DWORDLONG;
    dwlMinPreviewFileSize: DWORDLONG;
    dwlMaxPreviewFileSize: DWORDLONG;
    uiMajorFileType: UINT;
    idPlugin: TGUID;
    dwOpusVerMajor: DWORD;
    dwOpusVerMinor: DWORD;
    dwInitFlags: DWORD;
  end;

  VIEWERPLUGININFOW = record
    cbSize: UINT;
    dwFlags: DWORD;
    dwVersionHigh: DWORD;
    dwVersionLow: DWORD;
    lpszHandleExts: LPWSTR;
    lpszName: LPWSTR;
    lpszDescription: LPWSTR;
    lpszCopyright: LPWSTR;
    lpszURL: LPWSTR;
    cchHandleExtsMax: UINT;
    cchNameMax: UINT;
    cchDescriptionMax: UINT;
    cchCopyrightMax: UINT;
    cchURLMax: UINT;
    dwlMinFileSize: DWORDLONG;
    dwlMaxFileSize: DWORDLONG;
    dwlMinPreviewFileSize: DWORDLONG;
    dwlMaxPreviewFileSize: DWORDLONG;
    uiMajorFileType: UINT;
    idPlugin: TGUID;
    dwOpusVerMajor: DWORD;
    dwOpusVerMinor: DWORD;
    dwInitFlags: DWORD;
    hIconSmall: HICON;
    hIconLarge: HICON;
  end;
  LPVIEWERPLUGININFOW = ^VIEWERPLUGININFOW;

  TVIEWERPLUGININFOAV1 = record
    cbSize: UINT;
    dwFlags: DWORD;
    dwVersionHigh: DWORD;
    dwVersionLow: DWORD;
    lpszHandleExts: LPSTR;
    lpszName: LPSTR;
    lpszDescription: LPSTR;
    lpszCopyright: LPSTR;
    lpszURL: LPSTR;
    cchHandleExtsMax: UINT;
    cchNameMax: UINT;
    cchDescriptionMax: UINT;
    cchCopyrightMax: UINT;
    cchURLMax: UINT;
    dwlMinFileSize: DWORDLONG;
    dwlMaxFileSize: DWORDLONG;
    dwlMinPreviewFileSize: DWORDLONG;
    dwlMaxPreviewFileSize: DWORDLONG;
    uiMajorFileType: UINT;
    idPlugin: TGUID;
  end;

  TVIEWERPLUGININFOAV4 = record
    cbSize: UINT;
    dwFlags: DWORD;
    dwVersionHigh: DWORD;
    dwVersionLow: DWORD;
    lpszHandleExts: LPSTR;
    lpszName: LPSTR;
    lpszDescription: LPSTR;
    lpszCopyright: LPSTR;
    lpszURL: LPSTR;
    cchHandleExtsMax: UINT;
    cchNameMax: UINT;
    cchDescriptionMax: UINT;
    cchCopyrightMax: UINT;
    cchURLMax: UINT;
    dwlMinFileSize: DWORDLONG;
    dwlMaxFileSize: DWORDLONG;
    dwlMinPreviewFileSize: DWORDLONG;
    dwlMaxPreviewFileSize: DWORDLONG;
    uiMajorFileType: UINT;
    idPlugin: TGUID;
    dwOpusVerMajor: DWORD;
    dwOpusVerMinor: DWORD;
    dwInitFlags: DWORD;
  end;

  VIEWERPLUGININFOA = record
    cbSize: UINT;
    dwFlags: DWORD;
    dwVersionHigh: DWORD;
    dwVersionLow: DWORD;
    lpszHandleExts: LPSTR;
    lpszName: LPSTR;
    lpszDescription: LPSTR;
    lpszCopyright: LPSTR;
    lpszURL: LPSTR;
    cchHandleExtsMax: UINT;
    cchNameMax: UINT;
    cchDescriptionMax: UINT;
    cchCopyrightMax: UINT;
    cchURLMax: UINT;
    dwlMinFileSize: DWORDLONG;
    dwlMaxFileSize: DWORDLONG;
    dwlMinPreviewFileSize: DWORDLONG;
    dwlMaxPreviewFileSize: DWORDLONG;
    uiMajorFileType: UINT;
    idPlugin: TGUID;
    dwOpusVerMajor: DWORD;
    dwOpusVerMinor: DWORD;
    dwInitFlags: DWORD;
    hIconSmall: HICON;
    hIconLarge: HICON;
  end;
  LPVIEWERPLUGININFOA = ^VIEWERPLUGININFOA;

  VIEWERPLUGININFO = VIEWERPLUGININFOW;
  LPVIEWERPLUGININFO = LPVIEWERPLUGININFOW;

  TVIEWERPLUGINFILEINFOWV1 = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPWSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
  end;

  TVIEWERPLUGINFILEINFOWV2 = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPWSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
    szResolution: SIZE;
    iTypeHint: Integer;
  end;

  TVIEWERPLUGINFILEINFOWV3 = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPWSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
    szResolution: SIZE;
    iTypeHint: Integer;
    crTransparentColor: COLORREF;
    wThumbnailQuality: Word;
    dwlFileSize: DWORDLONG;
  end;

  VIEWERPLUGINFILEINFOW = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPWSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
    szResolution: SIZE;
    iTypeHint: Integer;
    crTransparentColor: COLORREF;
    wThumbnailQuality: Word;
    dwlFileSize: DWORDLONG;
    iColorSpace: Integer;
  end;
  LPVIEWERPLUGINFILEINFOW = ^VIEWERPLUGINFILEINFOW;

  TVIEWERPLUGINFILEINFOAV1 = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
  end;

  TVIEWERPLUGINFILEINFOAV2 = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
    szResolution: SIZE;
    iTypeHint: Integer;
  end;

  TVIEWERPLUGINFILEINFOAV3 = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
    szResolution: SIZE;
    iTypeHint: Integer;
    crTransparentColor: COLORREF;
    wThumbnailQuality: Word;
    dwlFileSize: DWORDLONG;
  end;

  VIEWERPLUGINFILEINFOA = record
    cbSize: UINT;
    dwFlags: DWORD;
    wMajorType: Word;
    wMinorType: Word;
    szImageSize: SIZE;
    iNumBits: Integer;
    lpszInfo: LPSTR;
    cchInfoMax: UINT;
    dwPrivateData: array[0..7] of DWORD;
    szResolution: SIZE;
    iTypeHint: Integer;
    crTransparentColor: COLORREF;
    wThumbnailQuality: Word;
    dwlFileSize: DWORDLONG;
    iColorSpace: Integer;
  end;
  LPVIEWERPLUGINFILEINFOA = ^VIEWERPLUGINFILEINFOA;

  VIEWERPLUGINFILEINFO = VIEWERPLUGINFILEINFOW;
  LPVIEWERPLUGINFILEINFO = LPVIEWERPLUGINFILEINFOW;

const
  VIEWERPLUGINFILEINFOW_V1_SIZE = 68;
  VIEWERPLUGINFILEINFOW_V2_SIZE = SizeOf(TVIEWERPLUGINFILEINFOWV2);
  VIEWERPLUGINFILEINFOW_V3_SIZE = SizeOf(TVIEWERPLUGINFILEINFOWV3);
  VIEWERPLUGINFILEINFOW_V4_SIZE = SizeOf(VIEWERPLUGINFILEINFOW);
  VIEWERPLUGINFILEINFOA_V1_SIZE = 68;
  VIEWERPLUGINFILEINFOA_V2_SIZE = SizeOf(TVIEWERPLUGINFILEINFOAV2);
  VIEWERPLUGINFILEINFOA_V3_SIZE = SizeOf(TVIEWERPLUGINFILEINFOAV3);
  VIEWERPLUGINFILEINFOA_V4_SIZE = SizeOf(VIEWERPLUGINFILEINFOA);
  VIEWERPLUGINFILEINFO_V1_SIZE = VIEWERPLUGINFILEINFOW_V1_SIZE;
  VIEWERPLUGINFILEINFO_V2_SIZE = VIEWERPLUGINFILEINFOW_V2_SIZE;
  VIEWERPLUGINFILEINFO_V3_SIZE = VIEWERPLUGINFILEINFOW_V3_SIZE;
  VIEWERPLUGINFILEINFO_V4_SIZE = VIEWERPLUGINFILEINFOW_V4_SIZE;

type
  DVPNMSIZECHANGE = record
    hdr: NMHDR;
    szSize: SIZE;
  end;
  LPDVPNMSIZECHANGE = ^DVPNMSIZECHANGE;

  DVPNMCLICK = record
    hdr: NMHDR;
    pt: TPoint;
    fMenu: BOOL;
  end;
  LPDVPNMCLICK = ^DVPNMCLICK;

  DVPNMRESETZOOM = record
    hdr: NMHDR;
    iZoom: Integer;
  end;
  LPDVPNMRESETZOOM = ^DVPNMRESETZOOM;

  DVPNMFOCUSCHANGE = record
    hdr: NMHDR;
    fGotFocus: BOOL;
  end;
  LPDVPNMFOCUSCHANGE = ^DVPNMFOCUSCHANGE;

  DVPNMCAPABILITIES = record
    hdr: NMHDR;
    dwCapabilities: DWORD;
  end;
  LPDVPNMCAPABILITIES = ^DVPNMCAPABILITIES;

  DVPNMSTATUSTEXT = record
    hdr: NMHDR;
    lpszStatusText: LPWSTR;
    fUnicode: BOOL;
  end;
  LPDVPNMSTATUSTEXT = ^DVPNMSTATUSTEXT;

  DVPNMLOADNEWFILE = record
    hdr: NMHDR;
    lpszFilename: LPWSTR;
    fUnicode: BOOL;
    lpStream: IStream;
  end;
  LPDVPNMLOADNEWFILE = ^DVPNMLOADNEWFILE;

  DVPNMSETCURSOR = record
    hdr: NMHDR;
    pt: TPoint;
    fMenu: BOOL;
    fCanScroll: BOOL;
    iCursor: Integer;
  end;
  LPDVPNMSETCURSOR = ^DVPNMSETCURSOR;

  DVPNMGAMMA = record
    hdr: NMHDR;
    fEnable: BOOL;
    dbGamma: Double;
  end;
  LPDVPNMGAMMA = ^DVPNMGAMMA;

  DVPNMBUTTONOPTS = record
    hdr: NMHDR;
    iLeft: Integer;
    iRight: Integer;
    iMiddle: Integer;
  end;
  LPDVPNMBUTTONOPTS = ^DVPNMBUTTONOPTS;

  DVPNMGETCURSORS = record
    hdr: NMHDR;
    hCurHandOpen: HCURSOR;
    hCurHandClosed: HCURSOR;
    hCurCrosshair: HCURSOR;
  end;
  LPDVPNMGETCURSORS = ^DVPNMGETCURSORS;

  DVPNMMOUSEWHEEL = record
    hdr: NMHDR;
    wParam: WPARAM;
    lParam: LPARAM;
  end;
  LPDVPNMMOUSEWHEEL = ^DVPNMMOUSEWHEEL;

  DVPNMHEXSTATE = record
    hdr: NMHDR;
    fState: BOOL;
  end;
  DVNMHEXSTATE = DVPNMHEXSTATE;
  LPDVPNMHEXSTATE = ^DVPNMHEXSTATE;

  DVPCONTEXTMENUITEMA = record
    lpszLabel: LPSTR;
    dwFlags: DWORD;
    uID: UINT;
  end;
  LPDVPCONTEXTMENUITEMA = ^DVPCONTEXTMENUITEMA;

  DVPCONTEXTMENUITEMW = record
    lpszLabel: LPWSTR;
    dwFlags: DWORD;
    uID: UINT;
  end;
  LPDVPCONTEXTMENUITEMW = ^DVPCONTEXTMENUITEMW;

  DVPCONTEXTMENUITEM = DVPCONTEXTMENUITEMW;
  LPDVPCONTEXTMENUITEM = LPDVPCONTEXTMENUITEMW;

  OPUSUSBSAFEDATA = record
    cbSize: UINT;
    pszOtherExports: LPWSTR;
    cchOtherExports: UINT;
  end;
  LPOPUSUSBSAFEDATA = ^OPUSUSBSAFEDATA;

  DVPLOADTEXTDATAA = record
    cbSize: UINT;
    dwFlags: DWORD;
    hWndParent: HWND;
    lpszFile: LPSTR;
    lpInStream: IStream;
    dwStreamFlags: DWORD;
    lpOutStream: IStream;
    iOutTextType: Integer;
    tchPreferredViewer: array[0..39] of AnsiChar;
    hAbortEvent: THandle;
  end;
  LPDVPLOADTEXTDATAA = ^DVPLOADTEXTDATAA;

  DVPLOADTEXTDATAW = record
    cbSize: UINT;
    dwFlags: DWORD;
    hWndParent: HWND;
    lpszFile: LPWSTR;
    lpInStream: IStream;
    dwStreamFlags: DWORD;
    lpOutStream: IStream;
    iOutTextType: Integer;
    tchPreferredViewer: array[0..39] of WideChar;
    hAbortEvent: THandle;
  end;
  LPDVPLOADTEXTDATAW = ^DVPLOADTEXTDATAW;

  DVPLOADTEXTDATA = DVPLOADTEXTDATAW;
  LPDVPLOADTEXTDATA = LPDVPLOADTEXTDATAW;

  DVPFILEINFOHEADER = record
    cbSize: UINT;
    uiMajorType: UINT;
    dwFlags: DWORD;
  end;
  LPDVPFILEINFOHEADER = ^DVPFILEINFOHEADER;

  DVPFILEINFOMUSICA = record
    hdr: DVPFILEINFOHEADER;
    lpszAlbum: LPSTR;
    cchAlbumMax: UINT;
    lpszArtist: LPSTR;
    cchArtistMax: UINT;
    lpszTitle: LPSTR;
    cchTitleMax: UINT;
    lpszGenre: LPSTR;
    cchGenreMax: UINT;
    lpszComment: LPSTR;
    cchCommentMax: UINT;
    lpszFormat: LPSTR;
    cchFormatMax: UINT;
    lpszEncoder: LPSTR;
    cchEncoderMax: UINT;
    dwBitRate: DWORD;
    dwSampleRate: DWORD;
    dwDuration: DWORD;
    iTrackNum: Integer;
    iYear: Integer;
    iNumChannels: Integer;
    dwMusicFlags: DWORD;
    lpszCodec: LPSTR;
    cchCodecMax: UINT;
  end;
  LPDVPFILEINFOMUSICA = ^DVPFILEINFOMUSICA;

  DVPFILEINFOMUSICW = record
    hdr: DVPFILEINFOHEADER;
    lpszAlbum: LPWSTR;
    cchAlbumMax: UINT;
    lpszArtist: LPWSTR;
    cchArtistMax: UINT;
    lpszTitle: LPWSTR;
    cchTitleMax: UINT;
    lpszGenre: LPWSTR;
    cchGenreMax: UINT;
    lpszComment: LPWSTR;
    cchCommentMax: UINT;
    lpszFormat: LPWSTR;
    cchFormatMax: UINT;
    lpszEncoder: LPWSTR;
    cchEncoderMax: UINT;
    dwBitRate: DWORD;
    dwSampleRate: DWORD;
    dwDuration: DWORD;
    iTrackNum: Integer;
    iYear: Integer;
    iNumChannels: Integer;
    dwMusicFlags: DWORD;
    lpszCodec: LPWSTR;
    cchCodecMax: UINT;
  end;
  LPDVPFILEINFOMUSICW = ^DVPFILEINFOMUSICW;

  DVPFILEINFOMUSIC = DVPFILEINFOMUSICW;
  LPDVPFILEINFOMUSIC = LPDVPFILEINFOMUSICW;

  DVPFILEINFOMOVIEA = record
    hdr: DVPFILEINFOHEADER;
    szVideoSize: SIZE;
    iNumBits: Integer;
    dwDuration: DWORD;
    dwFrames: DWORD;
    flFrameRate: Double;
    dwDataRate: DWORD;
    ptAspectRatio: TPoint;
    dwAudioBitRate: DWORD;
    dwAudioSampleRate: DWORD;
    iNumChannels: Integer;
    lpszVideoCodec: LPSTR;
    cchVideoCodecMax: UINT;
    lpszAudioCodec: LPSTR;
    cchAudioCodecMax: UINT;
  end;
  LPDVPFILEINFOMOVIEA = ^DVPFILEINFOMOVIEA;

  DVPFILEINFOMOVIEW = record
    hdr: DVPFILEINFOHEADER;
    szVideoSize: SIZE;
    iNumBits: Integer;
    dwDuration: DWORD;
    dwFrames: DWORD;
    flFrameRate: Double;
    dwDataRate: DWORD;
    ptAspectRatio: TPoint;
    dwAudioBitRate: DWORD;
    dwAudioSampleRate: DWORD;
    iNumChannels: Integer;
    lpszVideoCodec: LPWSTR;
    cchVideoCodecMax: UINT;
    lpszAudioCodec: LPWSTR;
    cchAudioCodecMax: UINT;
  end;
  LPDVPFILEINFOMOVIEW = ^DVPFILEINFOMOVIEW;

  DVPFILEINFOMOVIE = DVPFILEINFOMOVIEW;
  LPDVPFILEINFOMOVIE = LPDVPFILEINFOMOVIEW;

  DVPINITEXDATA = record
    cbSize: UINT;
    hwndDOpusMsgWindow: HWND;
    dwOpusVerMajor: DWORD;
    dwOpusVerMinor: DWORD;
    pszLanguageName: LPWSTR;
  end;
  LPDVPINITEXDATA = ^DVPINITEXDATA;

  PFNDVPINIT = function: BOOL; cdecl;
  PFNDVPINITEX = function(pInitExData: LPDVPINITEXDATA): BOOL; cdecl;
  PFNDVPUSBSAFE = function(pUSBSafeData: LPOPUSUSBSAFEDATA): BOOL; cdecl;
  PFNDVPUNINIT = procedure; cdecl;
  PFNDVPIDENTIFYA = function(lpVPInfo: LPVIEWERPLUGININFOA): BOOL; cdecl;
  PFNDVPIDENTIFYW = function(lpVPInfo: LPVIEWERPLUGININFOW): BOOL; cdecl;
  PFNDVPIDENTIFYFILEA = function(hWnd: HWND; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; hAbortEvent: THandle): BOOL; cdecl;
  PFNDVPIDENTIFYFILEW = function(hWnd: HWND; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; hAbortEvent: THandle): BOOL; cdecl;
  PFNDVPIDENTIFYFILESTREAMA = function(hWnd: HWND; lpStream: IStream; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; dwStreamFlags: DWORD): BOOL; cdecl;
  PFNDVPIDENTIFYFILESTREAMW = function(hWnd: HWND; lpStream: IStream; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; dwStreamFlags: DWORD): BOOL; cdecl;
  PFNDVPIDENTIFYFILEBYTESA = function(hWnd: HWND; lpszName: LPSTR; lpData: LPBYTE; uiDataSize: UINT; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; dwStreamFlags: DWORD): BOOL; cdecl;
  PFNDVPIDENTIFYFILEBYTESW = function(hWnd: HWND; lpszName: LPWSTR; lpData: LPBYTE; uiDataSize: UINT; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; dwStreamFlags: DWORD): BOOL; cdecl;
  PFNDVPLOADBITMAPA = function(hWnd: HWND; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; lpszDesiredSize: PSIZE; hAbortEvent: THandle): HBITMAP; cdecl;
  PFNDVPLOADBITMAPW = function(hWnd: HWND; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; lpszDesiredSize: PSIZE; hAbortEvent: THandle): HBITMAP; cdecl;
  PFNDVPLOADBITMAPSTREAMA = function(hWnd: HWND; lpStream: IStream; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; lpszDesiredSize: PSIZE; dwStreamFlags: DWORD): HBITMAP; cdecl;
  PFNDVPLOADBITMAPSTREAMW = function(hWnd: HWND; lpStream: IStream; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; lpszDesiredSize: PSIZE; dwStreamFlags: DWORD): HBITMAP; cdecl;
  PFNDVPLOADTEXTA = function(lpLoadTextData: LPDVPLOADTEXTDATAA): BOOL; cdecl;
  PFNDVPLOADTEXTW = function(lpLoadTextData: LPDVPLOADTEXTDATAW): BOOL; cdecl;
  PFNDVPSHOWPROPERTIESA = function(hWndParent: HWND; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA): HWND; cdecl;
  PFNDVPSHOWPROPERTIESW = function(hWndParent: HWND; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW): HWND; cdecl;
  PFNDVPSHOWPROPERTIESSTREAMA = function(hWndParent: HWND; lpStream: IStream; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; dwStreamFlags: DWORD): HWND; cdecl;
  PFNDVPSHOWPROPERTIESSTREAMW = function(hWndParent: HWND; lpStream: IStream; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; dwStreamFlags: DWORD): HWND; cdecl;
  PFNDVPCREATEVIEWER = function(hWndParent: HWND; lpRc: PRECT; dwFlags: DWORD): HWND; cdecl;
  PFNDVPCONFIGURE = function(hWndParent: HWND; hWndNotify: HWND; dwNotifyData: DWORD): HWND; cdecl;
  PFNDVPABOUT = function(hWndParent: HWND): HWND; cdecl;
  PFNDVPGETFILEINFOFILEA = function(hWnd: HWND; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; lpFIH: LPDVPFILEINFOHEADER; hAbortEvent: THandle): BOOL; cdecl;
  PFNDVPGETFILEINFOFILEW = function(hWnd: HWND; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; lpFIH: LPDVPFILEINFOHEADER; hAbortEvent: THandle): BOOL; cdecl;
  PFNDVPGETFILEINFOFILESTREAMA = function(hWnd: HWND; lpStream: IStream; lpszName: LPSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOA; lpFIH: LPDVPFILEINFOHEADER; dwStreamFlags: DWORD): BOOL; cdecl;
  PFNDVPGETFILEINFOFILESTREAMW = function(hWnd: HWND; lpStream: IStream; lpszName: LPWSTR; lpVPFileInfo: LPVIEWERPLUGINFILEINFOW; lpFIH: LPDVPFILEINFOHEADER; dwStreamFlags: DWORD): BOOL; cdecl;

  PFNDVPIDENTIFY = PFNDVPIDENTIFYW;
  PFNDVPIDENTIFYFILE = PFNDVPIDENTIFYFILEW;
  PFNDVPIDENTIFYFILESTREAM = PFNDVPIDENTIFYFILESTREAMW;
  PFNDVPIDENTIFYFILEBYTES = PFNDVPIDENTIFYFILEBYTESW;
  PFNDVPLOADBITMAP = PFNDVPLOADBITMAPW;
  PFNDVPLOADBITMAPSTREAM = PFNDVPLOADBITMAPSTREAMW;
  PFNDVPLOADTEXT = PFNDVPLOADTEXTW;
  PFNDVPSHOWPROPERTIES = PFNDVPSHOWPROPERTIESW;
  PFNDVPSHOWPROPERTIESSTREAM = PFNDVPSHOWPROPERTIESSTREAMW;
  PFNDVPGETFILEINFOFILE = PFNDVPGETFILEINFOFILEW;
  PFNDVPGETFILEINFOFILESTREAM = PFNDVPGETFILEINFOFILESTREAMW;

implementation

end.



