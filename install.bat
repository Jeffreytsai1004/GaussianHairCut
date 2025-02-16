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
    echo Please install CUDA 11.8 from https://developer.nvidia.com/cuda-11-8-0-download-archive
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

REM 检查路径中是否包含空格
echo %PROJECT_DIR% | findstr /C:" " >nul
IF %ERRORLEVEL% EQU 0 (
    echo ERROR: Project path contains spaces: %PROJECT_DIR%
    echo Please move the project to a path without spaces
    exit /b 1
)

REM 检查必要的环境变量
IF NOT DEFINED PROJECT_DIR (
    echo 错误：未设置PROJECT_DIR环境变量
    exit /b 1
)

IF NOT DEFINED VS2019_VCVARS (
    echo 错误：未设置VS2019_VCVARS环境变量
    echo 请设置VS2019_VCVARS指向Visual Studio 2019的vcvars64.bat
    exit /b 1
)

REM 创建缓存目录
mkdir cache\gdown 2>nul
mkdir cache\torch 2>nul
mkdir cache\huggingface 2>nul

REM 创建ext目录并克隆仓库
mkdir ext 2>nul
cd ext

REM 克隆必要的仓库
git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1
cd openpose && git submodule update --init --recursive --remote
cd ..

git clone https://github.com/hustvl/Matte-Anything
cd Matte-Anything && git clone https://github.com/IDEA-Research/GroundingDINO.git
cd ..

git clone git@github.com:egorzakharov/NeuralHaircut.git --recursive
git clone https://github.com/facebookresearch/pytorch3d
cd pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
cd ..

git clone https://github.com/camenduru/simple-knn
cd diff_gaussian_rasterization_hair/third_party && git clone https://github.com/g-truc/glm
cd glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
cd ../..

git clone --recursive https://github.com/NVIDIAGameWorks/kaolin
cd kaolin && git checkout v0.15.0
cd ..

git clone https://github.com/SSL92/hyperIQA
cd ..

REM 创建环境
CALL "%MICROMAMBA_EXE%" env create -f environment.yml

REM 安装 gaussian_splatting_hair 环境
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair

REM 安装外部库
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
    echo 错误：未找到resource目录
    echo 请确保resource目录存在且包含以下必需文件：
    echo.
    echo resource/
    echo ├── NeuralHaircut/
    echo │   ├── pretrained_models/
    echo │   │   ├── diffusion_prior/
    echo │   │   │   └── dif_ckpt.pt
    echo │   │   └── strand_prior/
    echo │   │       └── strand_ckpt.pt
    echo │   └── PIXIE/
    echo │       └── pixie_data/
    echo ├── Matte-Anything/
    echo ├── openpose/
    echo └── hyperIQA/
    exit /b 1
)

REM 复制模型文件到对应位置
echo 正在复制模型文件...

REM 创建必要的目录
mkdir "%PROJECT_DIR%\ext\NeuralHaircut" 2>nul
mkdir "%PROJECT_DIR%\ext\NeuralHaircut\pretrained_models" 2>nul
mkdir "%PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior" 2>nul
mkdir "%PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\strand_prior" 2>nul
mkdir "%PROJECT_DIR%\ext\PIXIE" 2>nul
mkdir "%PROJECT_DIR%\ext\Matte-Anything\pretrained" 2>nul
mkdir "%PROJECT_DIR%\ext\openpose\models\pose\coco" 2>nul
mkdir "%PROJECT_DIR%\ext\hyperIQA\pretrained" 2>nul

xcopy /E /I /Y "%PROJECT_DIR%\resource\NeuralHaircut\*" "%PROJECT_DIR%\ext\NeuralHaircut\"
xcopy /E /I /Y "%PROJECT_DIR%\resource\NeuralHaircut\PIXIE\*" "%PROJECT_DIR%\ext\PIXIE"
xcopy /Y "%PROJECT_DIR%\resource\Matte-Anything\*" "%PROJECT_DIR%\ext\Matte-Anything\pretrained\"
xcopy /Y "%PROJECT_DIR%\resource\openpose\*" "%PROJECT_DIR%\ext\openpose\*"
xcopy /Y "%PROJECT_DIR%\resource\hyperIQA\*" "%PROJECT_DIR%\ext\hyperIQA\*"

REM 安装 PIXIE 环境
CALL activate_pixie-env.bat
cd %PROJECT_DIR%\ext\NeuralHaircut\PIXIE
echo 正在安装PIXIE依赖...
pip install pyyaml==5.4.1
pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59

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

REM 安装 OpenPose
CALL activate_openpose.bat
cd %PROJECT_DIR%\ext\openpose
mkdir build 2>nul
cd build
CALL "%VS2019_VCVARS%"
cmake .. -DBUILD_PYTHON=true -DUSE_CUDNN=off -DBUILD_CAFFE=false -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release
cd %PROJECT_DIR%

REM 检查资源文件是否已下载
IF NOT EXIST "resource" (
    echo 错误：未找到resource目录，请先运行download_resource.bat
    exit /b 1
)

REM 检查CUDA安装
IF NOT EXIST "%CUDA_HOME%" (
    echo 错误：未找到CUDA安装目录，请确保CUDA 11.8已正确安装
    exit /b 1
)

REM 检查Python版本
python -c "import sys; assert sys.version_info >= (3,8) and sys.version_info < (3,9), 'Python 3.8.x required'" || (
    echo 错误：需要Python 3.8.x版本
    exit /b 1
)

REM 检查CUDA版本
nvcc --version | findstr "release 11.8" >nul || (
    echo 错误：需要CUDA 11.8版本
    exit /b 1
)

REM 检查磁盘空间
for /f "tokens=3" %%a in ('dir /-c /w "%~d0\" ^| find "bytes free"') do set FREE_SPACE=%%a
if %FREE_SPACE% LSS 21474836480 (
    echo 错误：可用磁盘空间不足20GB
    exit /b 1
)

REM 创建环境激活脚本
echo @echo off > activate_gaussian_splatting_hair.bat
echo CALL "%%MICROMAMBA_EXE%%" activate -p %%MAMBA_ROOT_PREFIX%%\envs\gaussian_splatting_hair >> activate_gaussian_splatting_hair.bat

echo @echo off > activate_matte_anything.bat
echo CALL "%%MICROMAMBA_EXE%%" activate -p %%MAMBA_ROOT_PREFIX%%\envs\matte_anything >> activate_matte_anything.bat

echo @echo off > activate_openpose.bat
echo CALL "%%MICROMAMBA_EXE%%" activate -p %%MAMBA_ROOT_PREFIX%%\envs\openpose >> activate_openpose.bat

echo @echo off > activate_pixie-env.bat
echo CALL "%%MICROMAMBA_EXE%%" activate -p %%MAMBA_ROOT_PREFIX%%\envs\pixie-env >> activate_pixie-env.bat

echo Installation completed!
