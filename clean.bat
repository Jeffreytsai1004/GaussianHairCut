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
    "envs"
    "Scripts"
    "ext\openpose"
    "ext\Matte-Anything"
    "ext\NeuralHaircut"
    "ext\pytorch3d"
    "ext\simple-knn"
    "ext\diff_gaussian_rasterization_hair\third_party\glm"
    "ext\hyperIQA"
    "ext\kaolin"
    "ext\PIXIE"
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

# Search and remove broken packages
cd %USERPROFILE%\AppData\Roaming\Python\Python39\site-packages
dir *-info
# Remove all directories ending with "-info"
FOR %%D IN (*-info) DO (
    IF EXIST "%%~D" (
        ECHO Removing directory %%~D...
        RMDIR /S /Q "%%~D"
    )
)

ECHO Cleaning up micromamba cache...
SET "MAMBA_REQUEST_TIMEOUT=60"
CALL "%~dp0micromamba.exe" clean --all --yes

ECHO.
ECHO Clean complete.
PAUSE