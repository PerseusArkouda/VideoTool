@echo off
cls
title Video Tool
color 3F
echo Video Tool is starting
echo.

REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

set videotoolversion=1.00

:StartVideoTool
REM --> Check for update
setlocal enableextensions enabledelayedexpansion
for /f %%a in ('copy /Z "%~dpf0" nul') do set "ASCII_13=%%a"
set /p "=Checking for updates..." <NUL
if not exist "%AppData%\video-tool-bin" mkdir "%AppData%\video-tool-bin"
if not exist  "%AppData%\video-tool-bin\chooser.bat" powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PerseusArkouda/VideoTool/master/chooser.bat', '%AppData%\video-tool-bin\chooser.bat')"
if exist video-tool-bin rd /S /Q "video-tool-bin" 2> nul
if exist "%AppData%\chooser.bat" move /Y "%AppData%\chooser.bat" "%AppData%\video-tool-bin\" > nul
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PerseusArkouda/VideoTool/master/videotoolversiononline.txt', '%AppData%\video-tool-bin\videotoolversiononline.txt')"
set "onlineversionpath=%AppData%\video-tool-bin\videotoolversiononline.txt"
for /f "tokens=2" %%a in (!onlineversionpath!) do set videotoolversiononline=%%a
if exist "%AppData%\video-tool-bin\videotoolversiononline.txt" del /F /Q "%AppData%\video-tool-bin\videotoolversiononline.txt" 2> nul
if exist VideoTool.tmp del /F /Q VideoTool.tmp 2> nul
if exist VideoTool.bat.old move /Y VideoTool.bat.old "%AppData%\video-tool-bin\" > nul
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
if exist "%AppData%\video-tool-bin\list.txt" del /F /Q "%AppData%\video-tool-bin\list.txt" 2> nul
set /p "=x!ASCII_13!                            " <NUL

set "cleanvar=start" && goto Clean
:CleanStartOk

if not exist "%AppData%\video-tool-bin\ffmpeg.exe" goto FFMpegMissing

:Menu
cls
echo.
echo    _     _  _____  _____    ______  ______    _______  ______   ______   _      
echo   ^| ^|   ^| ^|  ^| ^|  ^| ^| \ \  ^| ^|     / ^|  ^| \     ^| ^|   / ^|  ^| \ / ^|  ^| \ ^| ^|     
echo   \ \   / /  ^| ^|  ^| ^|  ^| ^| ^| ^|---- ^| ^|  ^| ^|     ^| ^|   ^| ^|  ^| ^| ^| ^|  ^| ^| ^| ^|   _ 
echo    \_\_/_/  _^|_^|_ ^|_^|_/_/  ^|_^|____ \_^|__^|_/     ^|_^|   \_^|__^|_/ \_^|__^|_/ ^|_^|__^|_^| v%videotoolversion%
echo.
if %videotoolversiononline% GTR %videotoolversion% echo Notification: && echo --^> An updated version of Video Tool is available online. Type 10 to update...
:SkipVersionCheck
echo.
echo   1 - Download Video from Youtube
echo   2 - Download Audio from Youtube
echo.
echo   3 - Convert video to H264 MP4
echo   4 - Split Video
echo   5 - Merge Videos
echo   6 - Extract Segment of Video
echo   7 - Repair Broken Video
echo.
echo.
SET /P "menuchoice=Type choice number then press ENTER: "

IF [%menuchoice%]==[] echo You didn't put a proper value. Try again. && timeout 2 > nul && goto Menu
if %menuchoice%==1 goto DLVideo
if %menuchoice%==2 goto DLAudio
if %menuchoice%==3 goto Convert
if %menuchoice%==4 goto Split
if %menuchoice%==5 goto Merge
if %menuchoice%==6 goto Extract
if %menuchoice%==7 goto Repair
if %menuchoice%==10 (
goto Update
) else (
echo.
echo You didn't put a proper value. Try again.
timeout 2 > nul
goto Menu
)

:DLVideo
cls
echo.
echo This option will download a Youtube video with audio in the best possible quality.
echo Just paste the Youtube URL of the video or whole playlist.
echo.
echo.
set "videourl=null"
set /p "videourl=Paste here the URL: "
if not exist "VideoTool Export" mkdir "VideoTool Export"
echo "!videourl!" | FIND "list" > nul && (echo. && echo Downloading the playlist... && "%AppData%\video-tool-bin\youtube-dl.exe" -i -f "bestvideo[height>=720]+bestaudio[ext=m4a]/mp4" -o "VideoTool Export\%%(playlist)s\%%(playlist_index)s - %%(title)s.%%(ext)s" !videourl!) || (echo. && echo Downloading the Video... && "%AppData%\video-tool-bin\youtube-dl.exe" -f "bestvideo[height>=720]+bestaudio[ext=m4a]/mp4" --merge-output-format mp4 -o "VideoTool Export\%%(title)s.%%(ext)s" !videourl!)
echo Done.
echo.
echo Press any key to go back to main Menu...
pause > nul
goto Menu

:DLAudio
cls
echo.
echo This option will download the Audio as MP3 from a Youtube video in the best possible quality.
echo Just paste the Youtube URL of the video.
echo.
echo.
set "videourl=null"
set /p "videourl=Paste here the URL: "
echo "!videourl!" | FIND "list" > nul && (echo. && echo Downloading the MP3s from playlist... && "%AppData%\video-tool-bin\youtube-dl.exe" -i -f "bestvideo[height>=720]+bestaudio[ext=m4a]" -o "VideoTool Export\%%(playlist)s\%%(playlist_index)s - %%(title)s.%%(ext)s" -x --audio-format mp3 --audio-quality 0 !videourl!) || (echo. && echo Downloading the MP3 from Video... && "%AppData%\video-tool-bin\youtube-dl.exe" -f "bestvideo[height>=720]+bestaudio[ext=m4a]" -o "VideoTool Export\%%(title)s.%%(ext)s" -x --audio-format mp3 --audio-quality 0 !videourl!)
echo Done.
echo.
echo Press any key to go back to main Menu...
pause > nul
goto Menu

:Convert
cls
echo.
echo This Option will convert almost any video format to H264 MP4.
echo Select if you prefer speed or quality ^(s for speed and q for quality^).
echo Then you can select one or more videos at once.
echo.
echo.
set "speedconfirm=quality"
set /p "speedconfirm=Do you prefer speed or quality? (s/q): "
:ConvertRetry
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
set newcount=0
call "%AppData%\video-tool-bin\chooser.bat"
call :VideoVariables "ConvertLoop"
:ConvertLoop
if not exist "%AppData%\video-tool-bin\videolist.txt" echo. && echo Something went wrong. Try again && timeout 2 > nul && goto ConvertRetry
set /a newcount+=1
echo.
echo Starting the video conversion process of !countedvideofile[%newcount%]!
echo.
set countedvideoext=!countedvideofile[%newcount%]:~0,-4!
if not exist "VideoTool Export" mkdir "VideoTool Export"
if %speedconfirm%==s "%AppData%\video-tool-bin\ffmpeg.exe" -loglevel error -hide_banner -stats -i "!countedfullvideofile[%newcount%]!" -f mp4 -vcodec libx264 -strict -2 -c copy "VideoTool Export\Converted-%countedvideoext%.mp4" && goto ConvertDone
"%AppData%\video-tool-bin\ffmpeg.exe" -loglevel error -hide_banner -stats -i "!countedfullvideofile[%newcount%]!" -f mp4 -vcodec libx264 -strict -2 "VideoTool Export\Converted-%countedvideoext%.mp4"
:ConvertDone
if %newcount%==%number% goto EndConvertLoop
goto ConvertLoop
:EndConvertLoop
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
echo Done.
echo.
echo Press any key to go back to main Menu...
pause > nul
goto Menu

:Split
cls
echo.
echo This option will split the video on the defined time and will output two videos.
echo Select if you prefer speed or quality ^(s for speed and q for quality^).
echo Enter split MM:SS ^(MM= Minutes, SS= Seconds^).
echo Then you can select one or more videos at once.
echo.
echo.
set "speedconfirm=quality"
set /p "speedconfirm=Do you prefer speed or quality? (s/q): "
set /p "splittime=Type the split time: "
:SplitRetry
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
set newcount=0
call "%AppData%\video-tool-bin\chooser.bat"
call :VideoVariables "SplitLoop"
:SplitLoop
if not exist "%AppData%\video-tool-bin\videolist.txt" echo. && echo Something went wrong. Try again && timeout 2 > nul && goto SplitRetry
set /a newcount+=1
echo.
echo Starting the video splitting process of !countedvideofile[%newcount%]!
echo.
if not exist "VideoTool Export" mkdir "VideoTool Export"
if %speedconfirm%==s "%AppData%\video-tool-bin\ffmpeg.exe" -loglevel panic -hide_banner -stats -accurate_seek -i "!countedfullvideofile[%newcount%]!" -ss 0 -t 00:%splittime%.0 -c copy "VideoTool Export\Split1-!countedvideofile[%newcount%]!"
if %speedconfirm%==s "%AppData%\video-tool-bin\ffmpeg.exe" -loglevel panic -hide_banner -stats -accurate_seek -ss 00:%splittime%.0 -i "!countedfullvideofile[%newcount%]!" -c copy "VideoTool Export\Split2-!countedvideofile[%newcount%]!" && goto SplitDone
"%AppData%\video-tool-bin\ffmpeg.exe" -loglevel panic -hide_banner -stats -accurate_seek -i "!countedfullvideofile[%newcount%]!" -ss 0 -t 00:%splittime%.0 "VideoTool Export\Split1-!countedvideofile[%newcount%]!"
"%AppData%\video-tool-bin\ffmpeg.exe" -loglevel panic -hide_banner -stats -accurate_seek -ss 00:%splittime%.0 -i "!countedfullvideofile[%newcount%]!" "VideoTool Export\Split2-!countedvideofile[%newcount%]!"
:SplitDone
if %newcount%==%number% goto EndSplitLoop
goto SplitLoop
:EndSplitLoop
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
echo Done.
echo.
echo Press any key to go back to main Menu...
pause > nul
goto Menu

:Merge
cls
echo.
echo This option will join two video files into one.
echo Select if you prefer speed or quality ^(s for speed and q for quality^).
echo Then select two videos to merge them together.
echo.
echo.
set "speedconfirm=quality"
set /p "speedconfirm=Do you prefer speed or quality? (s/q): "
:MergeRetry
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
set newcount=0
call "%AppData%\video-tool-bin\chooser.bat"
call :VideoVariables "MergeLoop"
:MergeLoop
if not exist "%AppData%\video-tool-bin\videolist.txt" echo. && echo Something went wrong. Try again && timeout 2 > nul && goto MergeRetry
set /a newcount+=1
echo.
echo Starting the video merging process of %countedvideofile[1]%
echo with %countedvideofile[2]%
echo.
if not exist "VideoTool Export" mkdir "VideoTool Export"
(echo file '!countedfullvideofile[1]!' & echo file '!countedfullvideofile[2]!' )>"%AppData%\video-tool-bin\list.txt"
if %speedconfirm%==s "%AppData%\video-tool-bin\ffmpeg.exe" -loglevel error -hide_banner -stats -safe 0 -f concat -i "%AppData%\video-tool-bin\list.txt"  -strict -2 -c copy "VideoTool Export\Merged-%countedvideofile[1]%-%countedvideofile[2]%" && goto MergeDone
"%AppData%\video-tool-bin\ffmpeg.exe" -loglevel error -hide_banner -stats -safe 0 -f concat -i "%AppData%\video-tool-bin\list.txt" "VideoTool Export\Merged-%countedvideofile[1]%-%countedvideofile[2]%"
:MergeDone
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
if exist "%AppData%\video-tool-bin\list.txt" del /F /Q "%AppData%\video-tool-bin\list.txt" 2> nul
echo Done.
echo.
echo Press any key to go back to main Menu...
pause > nul
goto Menu 

:Extract
cls
echo.
echo This option will extract the defined segment from a video file.
echo Select if you prefer speed or quality ^(s for speed and q for quality^).
echo Then input starting MM:SS and ending MM:SS time ^(MM= Minutes, SS= Seconds^).
echo Then select the video file you want to extract from.
echo.
echo.
set "speedconfirm=quality"
set /p "speedconfirm=Do you prefer speed or quality? (s/q): "
set /p "extractstart=Type the starting time: "
set /p "extractend=Type the ending time: "
:ExtractRetry
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
set newcount=0
call "%AppData%\video-tool-bin\chooser.bat"
call :VideoVariables "ExtractLoop"
:ExtractLoop
if not exist "%AppData%\video-tool-bin\videolist.txt" echo. && echo Something went wrong. Try again && timeout 2 > nul && goto ExtractRetry
set /a newcount+=1
echo.
echo Starting the video extracting process of %countedvideofile[1]%
echo.
if not exist "VideoTool Export" mkdir "VideoTool Export"
if %speedconfirm%==s "%AppData%\video-tool-bin\ffmpeg.exe" -loglevel error -hide_banner -stats -accurate_seek -i "%countedfullvideofile[1]%" -ss 00:%extractstart%.0 -to 00:%extractend%.0  -strict -2 -c copy "VideoTool Export\Segment-%countedvideofile[1]%" && goto ExtractDone
"%AppData%\video-tool-bin\ffmpeg.exe" -loglevel error -hide_banner -stats -accurate_seek -i "%countedfullvideofile[1]%" -ss 00:%extractstart%.0 -to 00:%extractend%.0 "VideoTool Export\Segment-%countedvideofile[1]%"
:ExtractDone
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
echo Done.
echo.
echo Press any key to go back to main Menu...
pause > nul
goto Menu 

:Repair
cls
echo.
echo This option will attempt to repair your broken video file.
echo You can select one or more videos at once.
echo.
echo.
:RepairRetry
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
set newcount=0
call "%AppData%\video-tool-bin\chooser.bat"
call :VideoVariables "RepairLoop"
:RepairLoop
if not exist "%AppData%\video-tool-bin\videolist.txt" echo. && echo Something went wrong. Try again && timeout 2 > nul && goto RepairRetry
set /a newcount+=1
echo.
echo Starting the video repairing process of !countedvideofile[%newcount%]!
echo.
if not exist "VideoTool Export" mkdir "VideoTool Export"
"%AppData%\video-tool-bin\ffmpeg.exe" -loglevel error -hide_banner -stats -err_detect ignore_err -i "!countedfullvideofile[%newcount%]!" -c copy "VideoTool Export\Fixed-!countedvideofile[%newcount%]!"
:RepairDone
if %newcount%==%number% goto EndRepairLoop
goto RepairLoop
:EndRepairLoop
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
echo Done.
echo.
echo Press any key to go back to main Menu...
pause > nul
goto Menu

:Update
cls
echo.
echo Updating Video Tool from v%videotoolversion% to v%videotoolversiononline%. Please wait...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PerseusArkouda/VideoTool/master/VideoTool.bat', 'VideoTool.tmp')" && (
fc /B VideoTool.tmp VideoTool.bat >nul|| (del /F /Q "%AppData%\video-tool-bin\VideoTool.bat.old" 2> nul && copy /y VideoTool.bat "%AppData%\video-tool-bin\VideoTool.bat.old" > nul && copy /y VideoTool.tmp VideoTool.bat && VideoTool.bat))
echo Done.
timeout 4 > nul
goto Menu

:FFMpegMissing
cls
echo.
echo It seems you are running Video Tool for the first time.
:RetryFFMpeg
echo Downloading required software. Please wait...
echo.
echo Downloading Youtube-DL...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://yt-dl.org/downloads/2019.06.08/youtube-dl.exe', '%AppData%\video-tool-bin\youtube-dl.exe')"
echo Done.
echo.
echo Downloading FFMpeg...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-4.1.3-win32-static.zip', '%AppData%\video-tool-bin\ffmpeg.zip')"
if not exist "%AppData%\video-tool-bin\youtube-dl.exe" echo. && echo Something went wrong. Trying again. && timeout 2 > nul && goto RetryFFMpeg
if not exist "%AppData%\video-tool-bin\ffmpeg.zip" echo. && echo Something went wrong. Trying again. && timeout 2 > nul && goto RetryFFMpeg
Call :UnZipFile "%AppData%\video-tool-bin\" "%AppData%\video-tool-bin\ffmpeg.zip" FFmpegUnzipDone
:FFMpegUnzipDone
move /Y "%AppData%\video-tool-bin\ffmpeg-4.1.3-win32-static\bin\ffmpeg.exe" "%AppData%\video-tool-bin\" > nul
rd /S /Q "%AppData%\video-tool-bin\ffmpeg-4.1.3-win32-static" 2> nul
del /F /Q "%AppData%\video-tool-bin\ffmpeg.zip" 2> nul
echo Done.
echo.
timeout 4 > nul
goto Menu

:VideoVariables
set count=0
set number=0
set "videolistpath=%AppData%\video-tool-bin\videolist.txt"
set "cmd=findstr /R /N "^^" "%AppData%\video-tool-bin\videolist.txt" | find /C ":""
for /f %%g in ('!cmd!') do set number=%%g
for /L %%i in (1,1,%number%) do (
for /f "tokens=*" %%a in (!videolistpath!) do (
set /a count+=1
set fullvideofile=%%a
set countedfullvideofile[!count!]=%%a
for /f "tokens=*" %%x in ('dir /b /a-d "!fullvideofile!"') do set countedvideofile[!count!]=%%x
)
)
goto %~1

:Clean
if exist "%AppData%\chooser.bat" del /F /Q "%AppData%\chooser.bat"
if exist "%AppData%\video-tool-bin\videolist.txt" del /F /Q "%AppData%\video-tool-bin\videolist.txt" 2> nul
if "%cleanvar%"=="start" goto CleanStartOk

:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%
goto %3

:Error
echo.
echo Error. Exiting.

:PauseIt
echo.
echo Press any key to continue...
pause > nul

:End
