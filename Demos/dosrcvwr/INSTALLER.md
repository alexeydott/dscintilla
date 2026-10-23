# DOSrcVwr installer

Build the Win64 plugin and combined Scintilla runtime first, then run
`build-dopus-plugin-installer.bat`. The script reads the version from
`bin64/DOSrcVwr.dll` and creates `bin64/DOSrcVwr-DOpusPlugin-x64.exe`.
It uses `D:\tools\InnoSetup\6\ISCC.exe`; set `ISCC` to override that path.

Setup detects Directory Opus through the per-user and machine-wide App Paths
registry entries, with the standard Program Files location as a fallback.
The destination page remains visible so a different installation or portable
copy can be selected. It requires a 64-bit `dopus.exe` and `dopusrt.exe`.

The payload consists of `DOSrcVwr.dll` and `scintilla64.dll`, installed into
the selected Opus directory's `Viewers` subfolder. No Opus configuration or
plugin preferences are overwritten. Setup requests administrator privileges.

If the selected Opus installation is running, Setup sends
`dopusrt.exe /CMD Close PROGRAM` and waits up to 20 seconds for it to exit.
If it remains running, Setup stops before replacing files; close Opus in
other Windows sessions and retry. It never forcibly terminates the process.
After installation, Opus is relaunched as the original user only if it was
previously running. Setup also attempts to restore it after cancellation or
an installation failure following shutdown.

This is a copy/update installer. It creates no uninstaller in the shared
Directory Opus directory and does not claim ownership of the shared
`scintilla64.dll` for removal.

## Settings, migration and USB export

All settings are read and written below `User Data\dosrcvwr`, beside the
Opus `ConfigFiles` directory. The path comes from `GetConfigPathW(OPUSPATH_CONFIG)`
(`ConfigFiles\Plugins`) and `..\..\User Data\dosrcvwr`; APPDATA is only a
fallback when the Opus API is unavailable.

On first access, the plugin moves the entire old `ConfigFiles\Plugins\dosrcvwr`
directory, including nested themes, other settings and `.bak` files. If User Data
already contains settings, those files win: missing files are added, and the
complete old tree is moved under `Legacy ConfigFiles Backup/<unique ID>` in the
new directory. No source files are deleted before a successful move. A failed
migration retains the old files and uses them if the new directory is absent.
The older standalone `ConfigFiles\dosrcvwr` path is also recognized.

Opus backs up and restores `User Data` recursively, including the migrated files
and legacy backup. Plugin DLLs are separate from configuration backups. For USB
export, the DLL embeds resource `OPUS/1`, declaring the plugin USB-safe and listing
`scintilla.dll` for x86 and `scintilla64.dll` for x64. `DVP_USBSafe` remains for
legacy hosts. Logging starts disabled and, when enabled by XML, writes inside the
resolved plugin directory instead of the workstation's APPDATA Logs directory.

See the [Opus developer's USB export documentation](https://resource.dopus.com/t/plugins-supporting-usb-export-in-opus-10-above/11500)
and [recursive User Data backup guidance](https://resource.dopus.com/t/yet-another-source-code-viewer-plugin-based-on-scintilla-control/59251/28).
