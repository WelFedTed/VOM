@echo off

setlocal enabledelayedexpansion

rem title VOM - Vigilant Output Minimizer

if "%~2"=="" (
    echo No argument provided. Please specify a file.
    exit /b
)
rem if "%~2"=="test.txt" copy test.txt.bak test.txt
if not exist "%~2" (
    echo File does not exist.
    exit /b
)

set "input=%~2"
set output=""
set "temp_file=temp.txt"
set /a target_size_in_bytes=0
set /a current_size_in_bytes=0
set /a pass_counter=0

if "%~1"=="c" (
    echo Compressing %input%...
    echo:
    goto Compress
)
if "%~1"=="d" (
    echo Decompressing %input%...
    echo:
    goto COUNT_EXTENSIONS
)


:COMPRESS
	set /a pass_counter+=1
	echo Pass %pass_counter%...
	barf.exe c %input% > temp.txt
	set /p output=<temp.txt
	rem read new filename from temp.txt
	for /f "tokens=5" %%a in (temp.txt) do (
	    set "output=%%a"
	)
	del temp.txt
	echo %output%

	for %%F in ("%output%") do set "current_size_in_bytes=%%~zF"
	echo %current_size_in_bytes% bytes
	echo:

	if %current_size_in_bytes% GTR %target_size_in_bytes% (
		set input=%output%
		goto COMPRESS
	)
	goto END


:DECOMPRESS
	set /a pass_counter-=1
	set /a current_pass=%pass_counter%-1
	echo Pass %current_pass%...
	barf.exe d %input% > temp.txt
	set /p output=<temp.txt
	rem read new filename from temp.txt
	for /f "tokens=5" %%a in (temp.txt) do (
	    set "output=%%a"
	)
	del temp.txt
	echo %output%

	if %pass_counter% GTR 1 (
		set input=%output%
		goto DECOMPRESS
	)
	goto END


:COUNT_EXTENSIONS
		for /f "delims=" %%a in ("%input%") do (
		    set "line=%%a"
		    for /l %%i in (0,1,255) do (
		        set "char=!line:~%%i,1!"
		        if "!char!"=="." (
		            set /a pass_counter+=1
		        )
		    )
		)
		rem echo Number of extensions: %pass_counter%
	goto DECOMPRESS


:END
	endlocal
	echo End of script