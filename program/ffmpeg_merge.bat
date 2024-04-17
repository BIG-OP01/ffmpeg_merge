@echo off
:: =========================================
:: �ѼƳ]�m
set mergelist=mergelist.txt
set extenOut=mp4
set filetype=merge
:: =========================================
:: �ϥΰ���R�O�覡�ˬd�t�Τ��O�_�w�w�ˤF ffmpeg
echo �ˬd ffmpeg . . .
timeout /t 1 >nul
:: ���� ffmpeg �����T���R�O�A�ñN�зǿ��~��X���s�ɦV��зǿ�X
ffmpeg -version >nul 2>&1

if %errorlevel% equ 0 (
	ffmpeg -version 2>&1 | findstr /C:"ffmpeg version"
	echo ffmpeg �w�w�˦b�t�Τ��C
) else (
    echo ffmpeg ���w�˦b�t�Τ��C
	timeout /t 1 >nul
	echo.
	echo �Ьd�\ ffmpeg �w�˻����H�F�Ѧp��w�� ffmpeg�C
	echo �U�����}�Ghttps://ffmpeg.org/download.html
	goto theEnd
)
timeout /t 2 >nul
cls
:: =========================================
:: �ˬd�X�ֲM��
echo �ˬd�X�ֲM�� . . .
timeout /t 1 >nul
if exist "%mergelist%" (
	echo �w�o�{�X�ֲM���ɮסC
) else (
	echo.
	echo ���o�{�X�ֲM���ɮסC
	(
		echo # �b���ɮפU��ϥ�"file"�R�O�N�n�X�֪�����v���W�٨̧ǦV�U�C�X�C
		echo # �R�O�榡�Gfile '�v���W��'
		echo # 
		echo # �d��
		echo # file '001.mp4'
		echo # file '002.mp4'
		echo # file '003.mp4'
		echo # file '008.mp4'
		echo # file '010.mp4'
		echo # 
		echo # �X�᪺֫���񶶧ǧY���G001--002--003--008--010
		echo # �Ф��n�N"#"�@�P�C�X��U��A�������ѲŸ��C
	) > %mergelist%
	echo �w�ͦ��X�ֲM���ɮ׽d�� %mergelist% �A�Ш̷ӽd����������g�n�X�֪��v���W�١C
	goto theEnd
)
timeout /t 2 >nul
cls
:: =========================================
:: �����e�ɶ� yyyyMMdd
for /f %%a in ('powershell -command "Get-Date -Format 'yyyyMMdd'"') do set mydatetime=%%a
set outputfile=%filetype%%mydatetime%
:: =========================================
:: ffmpeg�X��

ffmpeg -f concat -safe 0 -i %mergelist% -c copy %outputfile%.%extenOut%

:: �ˬdffmpeg�R�O���檬�A
if %errorlevel% neq 0 (
    echo ffmpeg�R�O���楢�ѡC
	echo ���˵��W���x�A�ìd�\ ffmpeg ���������C
	goto theEnd
)
:: =========================================
:: ����v������ HH:MM:SS.MICROSECONDS -> HHMMSS
for /f "tokens=1 delims=." %%t in ('ffprobe -v error -show_entries format^=duration -sexagesimal -of default^=noprint_wrappers^=1:nokey^=1 %outputfile%.%extenOut%') do set duration=%%t
set "duration=%duration::=%"
:: =========================================
:: �R�������ɮ�
if exist "%outputfile%_%duration%.%extenOut%" (
	goto overwrite
) else (
	goto notoverwrite
)
:overwrite
choice /t 5 /c:yn /d n /n /m "�ɮפw�s�b�A�O�_�л\(y/n):"
set overinput=%errorlevel%
if %overinput%==1 (
	del /q "%outputfile%_%duration%.%extenOut%"
)
if %overinput%==2 (
	del /q "%outputfile%.%extenOut%"
	echo.
	echo �ާ@�w�����C
	goto theEnd
)
:notoverwrite
:: =========================================
:: ���s�R�W�ɮ�
ren "%outputfile%.%extenOut%" "%outputfile%_%duration%.%extenOut%"
:: =========================================
echo.
echo �ɮ�%outputfile%_%duration%.%extenOut%��X����
:theEnd
echo �Ы����N�䵲�� . . .
pause >nul
exit /b


:: Author�GWYC 2024/04/13