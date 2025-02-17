@echo off
set PROJECT_DIR=%~dp0
cd %PROJECT_DIR%

REM 检查是否安装了python
if not exist "%PROJECT_DIR%\venv\Scripts\python.exe" (
    echo 错误：未找到python.exe
    echo 请确保python已安装并配置好环境变量
    exit /b 1
)

REM pip安装检查更新
python -m pip install --upgrade pip

REM 安装gdown
python -m pip install gdown

REM 安装7z
python -m pip install py7zr

REM 安装tar
python -m pip install tar

mkdir %PROJECT_DIR%\resource\NeuralHaircut\
cd %PROJECT_DIR%\resource\NeuralHaircut\
python -m gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
cd %PROJECT_DIR%\resource\NeuralHaircut\pretrained_models\diffusion_prior
python -m gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
mkdir %PROJECT_DIR%\resource\NeuralHaircut\PIXIE
cd %PROJECT_DIR%\resource\NeuralHaircut\PIXIE
python -m gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
7z x pixie_data.tar.gz -o./ && tar -xvzf pixie_data.tar.gz
mkdir %PROJECT_DIR%\resource\hyperIQA\pretrained
cd %PROJECT_DIR%\resource\hyperIQA\pretrained
python -m gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
cd %PROJECT_DIR%

mkdir %PROJECT_DIR%\resource\Matte-Anything\pretrained
cd %PROJECT_DIR%\resource\Matte-Anything\pretrained
wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
wget https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
python -m gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

mkdir %PROJECT_DIR%\resource\openpose\
cd %PROJECT_DIR%\resource\openpose\
python -m gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV && tar -xvzf models.tar.gz
