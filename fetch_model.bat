#!/bin/bash
@echo off
setlocal EnableDelayedExpansion

@CALL python -m pip install --upgrade pip
@CALL python -m pip install gdown wget py7zr unrar rarfile zipfile

:: URL encode function
:urlencode
set "_str=%~1"
set "_len=0"
set "_res="
:_loop
set "_chr=!_str:~%_len%,1!"
if not defined _chr goto :_done
if "!_chr!"==" " (set "_res=!_res!%%20") else (
    echo !_chr!|findstr /i "[a-z0-9.~-]" >nul
    if errorlevel 1 (
        cmd /c exit /b '!_chr!'
        set /a "_hex=!errorlevel!"
        call :_hex !_hex!
        set "_res=!_res!%%!_hex!"
    ) else set "_res=!_res!!_chr!"
)
set /a "_len+=1"
goto :_loop
:_done
echo !_res!
exit /b

:_hex
set "_hex=0123456789ABCDEF"
set /a "_d1=%1/16"
set /a "_d2=%1%%16"
for %%I in (!_d1!) do set "_h1=!_hex:~%%I,1!"
for %%I in (!_d2!) do set "_h2=!_hex:~%%I,1!"
set "_hex=!_h1!!_h2!"
exit /b

:: SMPL-X 2020 (neutral SMPL-X model with the FLAME 2020 expression blendshapes)
echo.
echo You need to register at https://smpl-x.is.tue.mpg.de
set /p "username=Username (SMPL-X):"
set /p "password=Password (SMPL-X):"
call :urlencode !username! > smplx_username.txt
set /p encoded_username=<smplx_username.txt
del smplx_username.txt
call :urlencode !password! > smplx_password.txt  
set /p encoded_password=<smplx_password.txt
del smplx_password.txt
curl --data "username=!encoded_username!&password=!encoded_password!" "https://download.is.tue.mpg.de/download.php?domain=smplx&sfile=SMPLX_NEUTRAL_2020.npz&resume=1" --output "./resource/PIXIE/data/SMPLX_NEUTRAL_2020.npz" --insecure --continue-at -

:: PIXIE pretrained model and utilities
echo.
echo You need to register at https://pixie.is.tue.mpg.de/
set /p "username=Username (PIXIE):"
set /p "password=Password (PIXIE):"
call :urlencode !username! > pixie_username.txt
set /p encoded_username=<pixie_username.txt
del pixie_username.txt
call :urlencode !password! > pixie_password.txt
set /p encoded_password=<pixie_password.txt
del pixie_password.txt
curl --data "username=!encoded_username!&password=!encoded_password!" "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=pixie_model.tar&resume=1" --output "./resource/PIXIE/data/pixie_model.tar" --insecure --continue-at -
curl --data "username=!encoded_username!&password=!encoded_password!" "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=utilities.zip&resume=1" --output "./resource/PIXIE/data/utilities.zip" --insecure --continue-at -

cd .\resource\PIXIE\data
7z x utilities.zip

cd ../../..



