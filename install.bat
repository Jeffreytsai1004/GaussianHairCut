@echo off
setlocal enabledelayedexpansion

REM 设置环境变量
SET MICROMAMBA_EXE=%~dp0micromamba.exe
SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
SET PATH=%CUDA_HOME%\bin;%PATH%
SET PROJECT_DIR=%~dp0
SET PYTHONDONTWRITEBYTECODE=1
SET GDOWN_CACHE=cache\gdown
SET TORCH_HOME=cache\torch
SET HF_HOME=cache\huggingface
SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
SET VS2019_DIR=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools
SET VS2019_VCVARS=%VS2019_DIR%\VC\Auxiliary\Build\vcvars64.bat

REM 检查micromamba
IF NOT EXIST "%MICROMAMBA_EXE%" (
    echo ERROR: micromamba not found at %MICROMAMBA_EXE%
    echo Please install micromamba from https://mamba.readthedocs.io/en/latest/installation.html
    exit /b 1
)

REM 设置micromamba根目录
SET MAMBA_ROOT_PREFIX=%PROJECT_DIR%\micromamba
IF NOT EXIST "%MAMBA_ROOT_PREFIX%" mkdir "%MAMBA_ROOT_PREFIX%"

REM 初始化micromamba
CALL "%MICROMAMBA_EXE%" shell init --prefix "%MAMBA_ROOT_PREFIX%"

REM 检查必要的环境和依赖
IF NOT EXIST "%CUDA_HOME%\" (
    echo ERROR: CUDA 11.8 not found at %CUDA_HOME%
    exit /b 1
)
IF NOT EXIST "%BLENDER_DIR%\" (
    echo ERROR: Blender 3.6 not found at %BLENDER_DIR%
    echo Please install Blender 3.6 from https://www.blender.org/download/lts/3-6/
    exit /b 1
)

REM 检查Visual Studio
IF NOT EXIST "%VS2019_VCVARS%" (
    echo ERROR: Visual Studio 2019 not found
    echo Please install Visual Studio 2019 Build Tools with C++ development tools
    exit /b 1
)

REM 检查COLMAP
where colmap >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: COLMAP not found in PATH
    echo.
    echo Please follow these steps to install COLMAP:
    echo 1. Download COLMAP from https://github.com/colmap/colmap/releases
    echo 2. Extract to a path without spaces (e.g., C:\COLMAP)
    echo 3. Add the COLMAP directory to your system PATH:
    echo    a. Open "System Properties" ^> "Environment Variables"
    echo    b. Under "System Variables", find and select "Path"
    echo    c. Click "Edit" ^> "New"
    echo    d. Add your COLMAP directory path (e.g., C:\COLMAP)
    echo    e. Click "OK" to save
    echo 4. Open a new terminal window and try again
    echo.
    echo Note: If you've just added COLMAP to PATH, you need to open
    echo a new terminal window for the changes to take effect.
    exit /b 1
)

REM 检查COLMAP是否可用
colmap -h >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: COLMAP installation appears to be broken
    echo Please try reinstalling COLMAP
    exit /b 1
)

REM 检查CUDA版本
nvcc --version 2>nul | findstr "release 11.8" >nul
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: CUDA 11.8 not found or version mismatch
    exit /b 1
)

REM 创建缓存目录
mkdir cache\gdown 2>nul
mkdir cache\torch 2>nul
mkdir cache\huggingface 2>nul

REM 创建ext目录
mkdir ext 2>nul
cd ext

REM 克隆外部库
git clone --depth 1 https://github.com/CMU-Perceptual-Computing-Lab/openpose
cd openpose
git submodule update --init --recursive --remote
cd ..

git clone https://github.com/hustvl/Matte-Anything
cd Matte-Anything
git clone https://github.com/IDEA-Research/GroundingDINO.git
cd ..

git clone https://github.com/egorzakharov/NeuralHaircut.git --recursive
git clone https://github.com/facebookresearch/pytorch3d
cd pytorch3d
git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
cd ..

git clone https://github.com/camenduru/simple-knn
cd diff_gaussian_rasterization_hair\third_party
git clone https://github.com/g-truc/glm
cd glm
git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
cd ..\..\..

git clone --recursive https://github.com/NVIDIAGameWorks/kaolin
cd kaolin
git checkout v0.15.0
cd ..

git clone https://github.com/SSL92/hyperIQA

REM 创建环境
CALL "%MICROMAMBA_EXE%" create -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair python=3.8 pytorch=2.0.0 torchvision pytorch-cuda=11.8 cmake ninja setuptools=58.2.0 -c pytorch -c nvidia -c conda-forge -y
CALL "%MICROMAMBA_EXE%" create -p %MAMBA_ROOT_PREFIX%\envs\matte_anything pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale supervision==0.22.0 -c pytorch -c nvidia -c conda-forge -y
CALL "%MICROMAMBA_EXE%" create -p %MAMBA_ROOT_PREFIX%\envs\openpose python=3.8 cmake=3.20 -c conda-forge -y
CALL "%MICROMAMBA_EXE%" create -p %MAMBA_ROOT_PREFIX%\envs\pixie-env python=3.8 pytorch=2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -c bottler -c iopath -y

REM 安装 gaussian_splatting_hair 环境
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
pip install -r requirements.txt
cd %PROJECT_DIR%\ext\pytorch3d
pip install -e .
cd %PROJECT_DIR%\ext\NeuralHaircut\npbgpp
pip install -e .
cd %PROJECT_DIR%\ext\simple-knn
pip install -e .
cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair
pip install -e .
cd %PROJECT_DIR%\ext\kaolin
pip install -e .
cd %PROJECT_DIR%

REM 检查resource目录
IF NOT EXIST "%PROJECT_DIR%\resource" (
    echo ERROR: resource directory not found
    echo Please ensure the resource directory exists with required files:
    echo.
    echo resource/
    echo ├── NeuralHaircut/
    echo │   ├── diffusion_prior/
    echo │   └── PIXIE/
    echo ├── Matte-Anything/
    echo │   ├── sam_vit_h_4b8939.pth
    echo │   ├── groundingdino_swint_ogc.pth
    echo │   └── model.pth
    echo └── openpose/
    echo     └── models/
    exit /b 1
)

REM 下载 Neural Haircut 文件
cd %PROJECT_DIR%\ext\NeuralHaircut
xcopy /E /I /Y "%PROJECT_DIR%\resource\NeuralHaircut\*" .
cd pretrained_models\diffusion_prior
xcopy /Y "%PROJECT_DIR%\resource\NeuralHaircut\diffusion_prior\*" .
cd ..\..\PIXIE
xcopy /E /I /Y "%PROJECT_DIR%\resource\NeuralHaircut\PIXIE\*" .

REM 安装 Matte-Anything 环境
CALL activate_matte_anything.bat
cd %PROJECT_DIR%\ext\Matte-Anything

REM 安装SAM和detectron2
pip install git+https://github.com/facebookresearch/segment-anything.git
pip install 'git+https://github.com/facebookresearch/detectron2.git'
cd GroundingDINO
pip install -e .
cd ..
pip install supervision==0.22.0

mkdir pretrained 2>nul
cd pretrained
xcopy /Y "%PROJECT_DIR%\resource\Matte-Anything\*" .
cd ..
xcopy /Y "%PROJECT_DIR%\resource\Matte-Anything\model.pth" .

REM 安装 OpenPose 模型
cd %PROJECT_DIR%\ext\openpose
xcopy /E /I /Y "%PROJECT_DIR%\resource\openpose\models\*" models\

REM 复制 hyperIQA 模型
cd %PROJECT_DIR%\ext\hyperIQA
mkdir pretrained 2>nul
xcopy /Y "%PROJECT_DIR%\resource\hyperIQA\pretrained\*" pretrained\

REM 安装 PIXIE 环境
CALL activate_pixie-env.bat
cd %PROJECT_DIR%\ext\PIXIE
pip install pyyaml==5.4.1
pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59

echo Installation completed!
