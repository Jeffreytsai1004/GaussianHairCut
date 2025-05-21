@ECHO OFF
@SETLOCAL EnableDelayedExpansion

@REM Set local paths
@SET "PROJECT_DIR=%~dp0"
@SET "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

@IF EXIST "%PROJECT_DIR%\cache" RMDIR /S /Q "%PROJECT_DIR%\cache"
@IF EXIST "%PROJECT_DIR%\condabin" RMDIR /S /Q "%PROJECT_DIR%\condabin"
@IF EXIST "%PROJECT_DIR%\pkgs" RMDIR /S /Q "%PROJECT_DIR%\pkgs"
@IF EXIST "%PROJECT_DIR%\envs" RMDIR /S /Q "%PROJECT_DIR%\envs"
@IF EXIST "%PROJECT_DIR%\Scripts" RMDIR /S /Q "%PROJECT_DIR%\Scripts"
@IF EXIST "%PROJECT_DIR%\ext\hyperIQA" RMDIR /S /Q "%PROJECT_DIR%\ext\hyperIQA"
@IF EXIST "%PROJECT_DIR%\ext\kaolin" RMDIR /S /Q "%PROJECT_DIR%\ext\kaolin"
@IF EXIST "%PROJECT_DIR%\ext\Matte-Anything" RMDIR /S /Q "%PROJECT_DIR%\ext\Matte-Anything"
@IF EXIST "%PROJECT_DIR%\ext\NeuralHaircut" RMDIR /S /Q "%PROJECT_DIR%\ext\NeuralHaircut"
@IF EXIST "%PROJECT_DIR%\ext\face-alignment" RMDIR /S /Q "%PROJECT_DIR%\ext\face-alignment"
@IF EXIST "%PROJECT_DIR%\ext\openpose" RMDIR /S /Q "%PROJECT_DIR%\ext\openpose"
@IF EXIST "%PROJECT_DIR%\ext\PIXIE" RMDIR /S /Q "%PROJECT_DIR%\ext\PIXIE"
@IF EXIST "%PROJECT_DIR%\ext\pytorch3d" RMDIR /S /Q "%PROJECT_DIR%\ext\pytorch3d"
@IF EXIST "%PROJECT_DIR%\ext\simple-knn" RMDIR /S /Q "%PROJECT_DIR%\ext\simple-knn"

@ECHO.
@ECHO Clean complete.
@PAUSE