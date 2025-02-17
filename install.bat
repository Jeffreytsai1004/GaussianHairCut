@echo off

REM 统一环境变量设置格式
set "PROJECT_DIR=%~dp0"
set "CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
set "PATH=%CUDA_HOME%\bin;%PATH%"
set "BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6"
set "VS_DIR=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools"
set "VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat"
set "MICROMAMBA_EXE=%PROJECT_DIR%micromamba.exe"
set "MAMBA_ROOT_PREFIX=%PROJECT_DIR%micromamba"
set "PYTHONDONTWRITEBYTECODE=1"
set "GDOWN_CACHE=%PROJECT_DIR%\cache\gdown"
set "TORCH_HOME=%PROJECT_DIR%\cache\torch"
set "HF_HOME=%PROJECT_DIR%\cache\huggingface"

REM 拉取所有外部库
mkdir ext
cd %PROJECT_DIR%\ext && git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1
cd %PROJECT_DIR%\ext\openpose && git submodule update --init --recursive --remote
cd %PROJECT_DIR%\ext && git clone https://github.com/hustvl/Matte-Anything
cd %PROJECT_DIR%\ext\Matte-Anything && git clone https://github.com/IDEA-Research/GroundingDINO.git
cd %PROJECT_DIR%\ext && git clone git@github.com:egorzakharov/NeuralHaircut.git --recursive
cd %PROJECT_DIR%\ext && git clone https://github.com/facebookresearch/pytorch3d
cd %PROJECT_DIR%\ext\pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
cd %PROJECT_DIR%\ext && git clone https://github.com/camenduru/simple-knn
cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party && git clone https://github.com/g-truc/glm
cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
cd %PROJECT_DIR%\ext && git clone --recursive https://github.com/NVIDIAGameWorks/kaolin
cd %PROJECT_DIR%\ext\kaolin && git checkout v0.15.0
cd %PROJECT_DIR%\ext && git clone https://github.com/SSL92/hyperIQA

REM 创建主环境
%MICROMAMBA_EXE% create -y -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair python=3.9
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
pip install -r requirements.txt
CALL %MICROMAMBA_EXE% deactivate

REM 创建 Matte-Anything 环境
%MICROMAMBA_EXE% create -y -p %MAMBA_ROOT_PREFIX%\envs\matte_anything python=3.9
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\matte_anything
pip install -r requirements_matte.txt
CALL %MICROMAMBA_EXE% deactivate

REM 创建 PIXIE 环境
%MICROMAMBA_EXE% create -y -p %MAMBA_ROOT_PREFIX%\envs\pixie-env python=3.8
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\pixie-env
pip install -r requirements_pixie.txt
CALL %MICROMAMBA_EXE% deactivate

REM 创建 OpenPose 环境
%MICROMAMBA_EXE% create -y -p %MAMBA_ROOT_PREFIX%\envs\openpose python=3.9
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\openpose
pip install -r requirements_openpose.txt
REM 从resource文件夹拷贝Neural Haircut文件
xcopy /E /I /Y %PROJECT_DIR%\resource\NeuralHaircut %PROJECT_DIR%\ext\NeuralHaircut
xcopy /E /I /Y %PROJECT_DIR%\resource\hyperIQA\pretrained %PROJECT_DIR%\ext\hyperIQA\pretrained
cd %PROJECT_DIR%
REM 退出 OpenPose 环境
CALL %MICROMAMBA_EXE% deactivate

REM Matte-Anything
%MICROMAMBA_EXE% create -y -n matte_anything pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale -c pytorch -c nvidia -c conda-forge
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\matte_anything
REM 安装pip
python -m pip install --upgrade pip
REM 安装segment-anything
pip install git+https://github.com/facebookresearch/segment-anything.git
REM 安装detectron2
python -m pip install 'git+https://github.com/facebookresearch/detectron2.git'
REM 安装GroundingDINO
cd %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
pip install -e .
REM 安装supervision 修复GroundingDINO错误
pip install supervision==0.22.0
REM 创建pretrained文件夹
cd %PROJECT_DIR%\ext\Matte-Anything && mkdir pretrained
cd %PROJECT_DIR%\ext\Matte-Anything\pretrained
xcopy /E /I /Y %PROJECT_DIR%\resource\Matte-Anything\pretrained\sam_vit_h_4b8939.pth %PROJECT_DIR%\ext\Matte-Anything\pretrained
xcopy /E /I /Y %PROJECT_DIR%\resource\Matte-Anything\pretrained\groundingdino_swint_ogc.pth %PROJECT_DIR%\ext\Matte-Anything\pretrained
REM 退出matte_anything环境
CALL %MICROMAMBA_EXE% deactivate
REM 进入gaussian_splatting_hair环境
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
REM 下载Neural Haircut文件
xcopy /E /I /Y %PROJECT_DIR%\resource\Matte-Anything\pretrained\model_best.pth %PROJECT_DIR%\ext\Matte-Anything\pretrained
REM 退出gaussian_splatting_hair环境
CALL %MICROMAMBA_EXE% deactivate

REM OpenPose
cd %PROJECT_DIR%\ext\openpose
xcopy /E /I /Y %PROJECT_DIR%\resource\openpose\models %PROJECT_DIR%\ext\openpose\models
REM 更新openpose子模块
git submodule update --init --recursive --remote
REM 创建openpose环境 避免cmake错误
%MICROMAMBA_EXE% create -y -p %MAMBA_ROOT_PREFIX%\envs\openpose cmake=3.20 -c conda-forge
REM 进入openpose环境
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\openpose
REM 创建build文件夹
mkdir build
cd build
REM 调用Visual Studio环境
CALL %VS_VCVARS%
REM 使用Visual Studio 2019构建
cmake .. -DBUILD_PYTHON=true -DUSE_CUDNN=off -DBUILD_CAFFE=false -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release
REM 退出openpose环境
CALL %MICROMAMBA_EXE% deactivate

REM PIXIE
cd %PROJECT_DIR%\ext && git clone https://github.com/yfeng95/PIXIE
cd %PROJECT_DIR%\ext\PIXIE
REM 创建data目录
mkdir data 2>nul
cd data
REM 从resource拷贝PIXIE模型文件
xcopy /E /I /Y %PROJECT_DIR%\resource\PIXIE\data %PROJECT_DIR%\ext\PIXIE\data
cd ..

REM 创建pixie环境
%MICROMAMBA_EXE% create -y -p %MAMBA_ROOT_PREFIX%\envs\pixie-env python=3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 ^
    pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib ^
    -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d
REM 进入pixie环境
CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\pixie-env
REM 安装pip
python -m pip install --upgrade pip
REM 安装pyyaml
pip install pyyaml==5.4.1
REM 安装face-alignment
pip install "git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59"
REM 退出pixie环境
CALL %MICROMAMBA_EXE% deactivate

REM 安装pip包
pip install pysdf==0.1.9 clean-fid==0.1.35 face-alignment==1.4.1 clip==0.2.0 ^
    torchdiffeq==0.2.3 torchsde==0.2.5 resize-right==0.0.2


