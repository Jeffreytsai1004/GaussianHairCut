@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM =======================================
REM Clear old cache and environment folders
REM =======================================
ECHO.
ECHO Cleaning old environment and cache directories...
FOR %%D IN (
    "cache"
    "condabin"
    "pkgs"
    "envs"
    "Scripts"
    "ext\PIXIE"
    "ext\kaolin"
    "ext\hyperIQA"
    "ext\openpose"
    "ext\pytorch3d"
    "ext\simple-knn"
    "ext\Matte-Anything"
    "ext\Matte-Anything\GroundingDINO"
    "ext\Matte-Anything\segment-anything"
    "ext\Matte-Anything\detectron2"
    "ext\NeuralHaircut"
    "ext\diff_gaussian_rasterization_hair\third_party\glm"
    "ext\PIXIE"
    "ext\PIXIE\face-alignment"
) DO (
    IF EXIST "%%~D" (
        ECHO Removing directory %%~D...
        RMDIR /S /Q "%%~D"
    )
)

ECHO Killing any running micromamba processes...
taskkill /F /IM micromamba.exe /T 2>NUL
taskkill /F /IM conda.exe /T 2>NUL
taskkill /F /IM python.exe /T 2>NUL
timeout /t 2 /nobreak >NUL

ECHO Cleaning up lock files in conda and project cache folders...
FOR %%P IN (
    "%USERPROFILE%\.conda\pkgs\cache"
    "D:\AI\Anaconda\pkgs\cache"
    "%PROJECT_DIR%\pkgs\cache"
) DO (
    IF EXIST "%%~P" (
        DEL /F /Q "%%~P\*.json" 2>NUL
        DEL /F /Q "%%~P\*.lock" 2>NUL
    )
)

ECHO Cleaning up micromamba cache...
SET "MAMBA_REQUEST_TIMEOUT=60"
CALL "%~dp0micromamba.exe" clean --all --yes

ECHO.
ECHO Clean complete.
PAUSE