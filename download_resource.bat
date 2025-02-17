@echo off
chcp 437 >nul
setlocal enabledelayedexpansion

REM Set environment variables
set "PROJECT_DIR=%~dp0"
set "PYTHONDONTWRITEBYTECODE=1"
set "GDOWN_CACHE=%PROJECT_DIR%\cache\gdown"
set "TORCH_HOME=%PROJECT_DIR%\cache\torch"
set "HF_HOME=%PROJECT_DIR%\cache\huggingface"

REM Check Python
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Python not found
    exit /b 1
)

REM Create directories
mkdir "%PROJECT_DIR%\cache\gdown" 2>nul
mkdir "%PROJECT_DIR%\cache\torch" 2>nul
mkdir "%PROJECT_DIR%\cache\huggingface" 2>nul
mkdir "%PROJECT_DIR%\resource\NeuralHaircut\pretrained_models\diffusion_prior" 2>nul
mkdir "%PROJECT_DIR%\resource\NeuralHaircut\PIXIE" 2>nul
mkdir "%PROJECT_DIR%\resource\Matte-Anything\pretrained" 2>nul
mkdir "%PROJECT_DIR%\resource\openpose\models" 2>nul
mkdir "%PROJECT_DIR%\resource\hyperIQA\pretrained" 2>nul

REM Install gdown
python -m pip install --upgrade pip gdown

REM Download model files
cd "%PROJECT_DIR%\resource\NeuralHaircut"
python -m gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8 || exit /b 1

cd "%PROJECT_DIR%\resource\NeuralHaircut\pretrained_models\diffusion_prior"
python -m gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f || exit /b 1

cd "%PROJECT_DIR%\resource\NeuralHaircut\PIXIE"
python -m gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf || exit /b 1

cd "%PROJECT_DIR%\resource\hyperIQA\pretrained"
python -m gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE || exit /b 1

cd "%PROJECT_DIR%\resource\Matte-Anything\pretrained"
curl -L https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth -o sam_vit_h_4b8939.pth || exit /b 1
curl -L https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth -o groundingdino_swint_ogc.pth || exit /b 1
python -m gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW || exit /b 1

cd "%PROJECT_DIR%\resource\openpose"
python -m gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV || exit /b 1
tar -xf models.tar.gz || exit /b 1

cd "%PROJECT_DIR%"
echo All resources downloaded successfully!
