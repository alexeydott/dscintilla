// Minimal wrl.h shim for bcc64x (Embarcadero Clang)
// Provides Microsoft::WRL::ComPtr used by Scintilla's Direct2D/DirectWrite code.
// The real wrl.h is part of the Windows SDK and is not compatible with MinGW/bcc64x ABI.
#pragma once
#include <wrl/client.h>
