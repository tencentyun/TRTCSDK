set gfproject=%~dp0
set dstpath=%gfproject%Release_EXEPacket
set liteavPath=%gfproject%..\..\..\sdk\liteav\liteav\Build\Bin\Win32\Release
set appPath=%gfproject%..\Build\Bin\Win32\Release
set resPath=%gfproject%..\res
set pdbpath=%gfproject%Release_EXEPacket_Pdb
#set nReturnCode=0

if exist "%gfproject%Release_EXEPacket" rd /s /q "%gfproject%Release_EXEPacket"
if not exist %gfproject%Release_EXEPacket mkdir %gfproject%Release_EXEPacket

if exist "%gfproject%Release_EXEPacket_Pdb" rd /s /q "%gfproject%Release_EXEPacket_Pdb"
if not exist %gfproject%Release_EXEPacket_Pdb mkdir %gfproject%Release_EXEPacket_Pdb


@rem clear error level
verify >nul

:: copy PE file
copy "%liteavPath%\liteav.dll" "%dstpath%\" /y
copy "%appPath%\TRTCApp.exe" "%dstpath%\" /y

copy "%appPath%\libmp4v2.dll" "%dstpath%\" /y
copy "%appPath%\msvcp100.dll" "%dstpath%\" /y
copy "%appPath%\msvcr100.dll" "%dstpath%\" /y
copy "%appPath%\QQAudioHook.dll" "%dstpath%\" /y
copy "%appPath%\QQAudioHookService.dll" "%dstpath%\" /y
copy "%appPath%\TRAE.dll" "%dstpath%\" /y
copy "%appPath%\saturn.dll" "%dstpath%\" /y
:: copy res file
xcopy "%resPath%\resouce" "%dstpath%\" /S /E

:: copy pdb file
copy "%liteavPath%\liteav.pdb" "%pdbpath%\" /y
copy "%appPath%\TRTCApp.pdb" "%pdbpath%\" /y
copy "%liteavPath%\liteav.dll" "%pdbpath%\" /y
copy "%appPath%\TRTCApp.exe" "%pdbpath%\" /y

goto succ
