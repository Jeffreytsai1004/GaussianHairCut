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
    "ext\NeuralHaircut"
    "ext\diff_gaussian_rasterization_hair\third_party"
    "ext\PIXIE\face-alignment"
) DO (
    IF EXIST "%%~D" (
        ECHO Removing directory %%~D...
        RMDIR /S /Q "%%~D"
    )
)

ECHO.
ECHO Clean complete.
PAUSE