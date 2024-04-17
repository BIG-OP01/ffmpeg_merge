@echo off
:: =========================================
:: 參數設置
set mergelist=mergelist.txt
set extenOut=mp4
set filetype=merge
:: =========================================
:: 使用執行命令方式檢查系統中是否已安裝了 ffmpeg
echo 檢查 ffmpeg . . .
timeout /t 1 >nul
:: 執行 ffmpeg 版本訊息命令，並將標準錯誤輸出重新導向到標準輸出
ffmpeg -version >nul 2>&1

if %errorlevel% equ 0 (
	ffmpeg -version 2>&1 | findstr /C:"ffmpeg version"
	echo ffmpeg 已安裝在系統中。
) else (
    echo ffmpeg 未安裝在系統中。
	timeout /t 1 >nul
	echo.
	echo 請查閱 ffmpeg 安裝說明以了解如何安裝 ffmpeg。
	echo 下載網址：https://ffmpeg.org/download.html
	goto theEnd
)
timeout /t 2 >nul
cls
:: =========================================
:: 檢查合併清單
echo 檢查合併清單 . . .
timeout /t 1 >nul
if exist "%mergelist%" (
	echo 已發現合併清單檔案。
) else (
	echo.
	echo 未發現合併清單檔案。
	(
		echo # 在本檔案下方使用"file"命令將要合併的完整影片名稱依序向下列出。
		echo # 命令格式：file '影片名稱'
		echo # 
		echo # 範例
		echo # file '001.mp4'
		echo # file '002.mp4'
		echo # file '003.mp4'
		echo # file '008.mp4'
		echo # file '010.mp4'
		echo # 
		echo # 合併後的播放順序即為：001--002--003--008--010
		echo # 請不要將"#"一同列出於下方，此為註解符號。
	) > %mergelist%
	echo 已生成合併清單檔案範本 %mergelist% ，請依照範本內說明填寫要合併的影片名稱。
	goto theEnd
)
timeout /t 2 >nul
cls
:: =========================================
:: 獲取當前時間 yyyyMMdd
for /f %%a in ('powershell -command "Get-Date -Format 'yyyyMMdd'"') do set mydatetime=%%a
set outputfile=%filetype%%mydatetime%
:: =========================================
:: ffmpeg合併

ffmpeg -f concat -safe 0 -i %mergelist% -c copy %outputfile%.%extenOut%

:: 檢查ffmpeg命令執行狀態
if %errorlevel% neq 0 (
    echo ffmpeg命令執行失敗。
	echo 請檢視上方日誌，並查閱 ffmpeg 相關說明。
	goto theEnd
)
:: =========================================
:: 獲取影片長度 HH:MM:SS.MICROSECONDS -> HHMMSS
for /f "tokens=1 delims=." %%t in ('ffprobe -v error -show_entries format^=duration -sexagesimal -of default^=noprint_wrappers^=1:nokey^=1 %outputfile%.%extenOut%') do set duration=%%t
set "duration=%duration::=%"
:: =========================================
:: 刪除重複檔案
if exist "%outputfile%_%duration%.%extenOut%" (
	goto overwrite
) else (
	goto notoverwrite
)
:overwrite
choice /t 5 /c:yn /d n /n /m "檔案已存在，是否覆蓋(y/n):"
set overinput=%errorlevel%
if %overinput%==1 (
	del /q "%outputfile%_%duration%.%extenOut%"
)
if %overinput%==2 (
	del /q "%outputfile%.%extenOut%"
	echo.
	echo 操作已取消。
	goto theEnd
)
:notoverwrite
:: =========================================
:: 重新命名檔案
ren "%outputfile%.%extenOut%" "%outputfile%_%duration%.%extenOut%"
:: =========================================
echo.
echo 檔案%outputfile%_%duration%.%extenOut%輸出完成
:theEnd
echo 請按任意鍵結束 . . .
pause >nul
exit /b


:: Author：WYC 2024/04/13