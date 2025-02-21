@echo off
setlocal enabledelayedexpansion

@CALL SET PROJECT_DIR=%~dp0

REM 创建基本目录结构
@CALL mkdir ext 2>nul
@CALL mkdir cache 2>nul
@CALL mkdir cache\gdown 2>nul
@CALL mkdir cache\torch 2>nul
@CALL mkdir cache\huggingface 2>nul
@CALL mkdir resource 2>nul
@CALL mkdir resource\NeuralHaircut\pretrained_models\diffusion_prior 2>nul
@CALL mkdir resource\NeuralHaircut\PIXIE 2>nul
@CALL mkdir resource\hyperIQA\pretrained 2>nul
@CALL mkdir resource\Matte-Anything\pretrained 2>nul
@CALL mkdir resource\openpose 2>nul
@CALL mkdir resource\PIXIE\data 2>nul

@CALL python -m pip install --upgrade pip
@CALL python -m pip install gdown wget

echo "Downloading NeuralHaircut..."
@CALL cd resource\NeuralHaircut
@CALL python -m gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
@CALL cd %PROJECT_DIR%
@CALL cd resource\NeuralHaircut\pretrained_models\diffusion_prior
@CALL python -m gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
@CALL cd %PROJECT_DIR%

echo "Downloading PIXIE..."
@CALL cd resource\NeuralHaircut\PIXIE
@CALL python -m gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
@CALL tar -xvzf pixie_data.tar.gz
@CALL cd %PROJECT_DIR%

echo "Downloading hyperIQA..."
@CALL cd resource\hyperIQA\pretrained
@CALL python -m gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
@CALL cd %PROJECT_DIR%

echo "Downloading Matte-Anything..."
@CALL cd resource\Matte-Anything\pretrained
@CALL curl -L -o sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL curl -L -o groundingdino_swint_ogc.pth https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL python -m gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW
@CALL cd %PROJECT_DIR%

echo "Downloading openpose..."
@CALL cd resource\openpose
@CALL python -m gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
@CALL tar -xvzf models.tar.gz
@CALL cd %PROJECT_DIR%

echo "Downloading SMPL-X 2020 (neutral SMPL-X model with the FLAME 2020 expression blendshapes)"
echo "You need to register at https://smpl-x.is.tue.mpg.de"
set /p SMPLX_USER="Username (SMPL-X): "
set /p SMPLX_PASS="Password (SMPL-X): "

echo "Downloading PIXIE pretrained model and utilities"
@CALL cd resource\PIXIE\data
@CALL wget --post-data "username=%SMPLX_USER%&password=%SMPLX_PASS%" "https://download.is.tue.mpg.de/download.php?domain=smplx&sfile=SMPLX_NEUTRAL_2020.npz&resume=1" -O SMPLX_NEUTRAL_2020.npz --no-check-certificate --continue
@CALL cd %PROJECT_DIR%

echo "You need to register at https://pixie.is.tue.mpg.de/"
set /p PIXIE_USER="Username (PIXIE): "
set /p PIXIE_PASS="Password (PIXIE): "

echo "Downloading PIXIE model..."
@CALL cd resource\PIXIE\data
@CALL wget --post-data "username=%PIXIE_USER%&password=%PIXIE_PASS%" "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=pixie_model.tar&resume=1" -O pixie_model.tar --no-check-certificate --continue
@CALL wget --post-data "username=%PIXIE_USER%&password=%PIXIE_PASS%" "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=utilities.zip&resume=1" -O utilities.zip --no-check-certificate --continue
@CALL tar -xvzf utilities.zip
@CALL cd %PROJECT_DIR%

echo "Check downloads"
if not exist "%PROJECT_DIR%\resource\NeuralHaircut\pretrained_models\diffusion_prior\dif_ckpt.pth" (
    echo ERROR: Failed to download NeuralHaircut models
    exit /b 1
)

if not exist "%PROJECT_DIR%\resource\Matte-Anything\pretrained\sam_vit_h_4b8939.pth" (
    echo ERROR: Failed to download SAM model
    exit /b 1
)

if not exist "%PROJECT_DIR%\resource\Matte-Anything\pretrained\sam_vit_h_4b8939.pth" (
    echo ERROR: Failed to download SAM model
    exit /b 1
)

if not exist "%PROJECT_DIR%\resource\Matte-Anything\pretrained\groundingdino_swint_ogc.pth" (
    echo ERROR: Failed to download GroundingDINO model
    exit /b 1
)

if not exist "%PROJECT_DIR%\resource\PIXIE\data\SMPLX_NEUTRAL_2020.npz" (
    echo ERROR: Failed to download SMPL-X model
    exit /b 1
)

if not exist "%PROJECT_DIR%\resource\PIXIE\data\pixie_model" (
    echo ERROR: Failed to download PIXIE model
    exit /b 1
)

if not exist "%PROJECT_DIR%\resource\PIXIE\data\utilities" (
    echo ERROR: Failed to download PIXIE utilities
    exit /b 1
)

if not exist "%PROJECT_DIR%\resource\PIXIE\data\SMPLX_NEUTRAL_2020.npz" (
    echo ERROR: Failed to download SMPLX_NEUTRAL_2020.npz
    exit /b 1
)


echo "Download complete"
pause













