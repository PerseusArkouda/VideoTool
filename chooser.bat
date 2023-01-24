<# : chooser.bat

@echo off
setlocal enableextensions enabledelayedexpansion

echo.
for /f %%a in ('copy /Z "%~dpf0" nul') do set "ASCII_13=%%a"
set /p "=Select your video files..." <NUL
timeout 5

for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
    echo %%~I>> "%AppData%\video-tool-bin\videolist.txt"
)
set /p "=x!ASCII_13!                            " <NUL
goto :EOF

: end Batch portion / begin PowerShell hybrid chimera #>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "Video Files (MP4, MOV, MPEG, MTS, MKV, AVI, FLV, MXF...)|*.mp4;*.mov;*.mpeg;*.mts;*.m2ts;*.mkv;*.avi;*.webm;*.bin;*.flv;*.hevc;*.m4v;*.3gp;*.mv;*.mxf;*.opus;*.m4a|All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }