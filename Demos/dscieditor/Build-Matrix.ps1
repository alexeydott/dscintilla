[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $env:TEMP ('DSciEditor-matrix-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
)
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
foreach ($platform in @('Win32', 'Win64')) {
    foreach ($mode in @('dll', 'static')) {
        $name = "$platform-$mode"
        $output = Join-Path $OutputDirectory $name
        $dcu = Join-Path $OutputDirectory "dcu-$name"
        New-Item -ItemType Directory -Path $output, $dcu -Force | Out-Null
        $static = ($mode -eq 'static').ToString().ToLowerInvariant()
        $batch = @('@echo off', 'call "D:\Embarcadero RAD Studio\23.0\bin\rsvars.bat"',
            'if errorlevel 1 exit /b 1', ('cd /d "' + $projectRoot + '"'),
            "msbuild Demos\dscieditor\DSciEditor.dproj /t:Rebuild /p:Config=Release /p:Platform=$platform /p:DSciStaticLink=$static /p:DCC_ExeOutput=`"$output`" /p:DCC_DcuOutput=`"$dcu`" /v:normal",
            'exit /b %errorlevel%')
        $batchPath = Join-Path $OutputDirectory "$name.cmd"
        $batch | Set-Content -LiteralPath $batchPath -Encoding Default
        $log = Join-Path $OutputDirectory "$name-build.log"
        Write-Host "Building $name"
        & $env:ComSpec /d /c "`"$batchPath`"" > $log 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Build failed: $log" }
        if ($mode -eq 'dll') {
            $dll = 'bin32\scintilla.dll'
            if ($platform -eq 'Win64') { $dll = 'bin64\scintilla64.dll' }
            Copy-Item -LiteralPath (Join-Path $projectRoot $dll) -Destination $output -Force
        }
        Write-Host "Built $output\DSciEditor.exe"
    }
}
# Each EXE sees the same ../settings layout as the normal bin32/bin64 outputs.
Copy-Item -LiteralPath (Join-Path $projectRoot 'settings') -Destination $OutputDirectory -Recurse -Force
Write-Host "Four builds ready in $OutputDirectory"
