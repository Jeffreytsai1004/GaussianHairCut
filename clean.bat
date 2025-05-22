@ECHO OFF
@SETLOCAL EnableDelayedExpansion

@REM Set local paths
@SET "PROJECT_DIR=%~dp0"
@SET "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

FOR %%D IN (
    "%PROJECT_DIR%\cache"
    "%PROJECT_DIR%\condabin"
    "%PROJECT_DIR%\pkgs"
    "%PROJECT_DIR%\envs"
    "%PROJECT_DIR%\Scripts"
    "%PROJECT_DIR%\ext\hyperIQA"
    "%PROJECT_DIR%\ext\kaolin"
    "%PROJECT_DIR%\ext\Matte-Anything"
    "%PROJECT_DIR%\ext\NeuralHaircut"
    "%PROJECT_DIR%\ext\face-alignment"
    "%PROJECT_DIR%\ext\openpose"
    "%PROJECT_DIR%\ext\PIXIE"
    "%PROJECT_DIR%\ext\pytorch3d"
    "%PROJECT_DIR%\ext\simple-knn"
) DO (
    IF EXIST "%%~D" (
        ECHO Removing directory %%~D...
        RMDIR /S /Q "%%~D"
    )
)

@ECHO.
@ECHO Clean complete.
@PAUSE