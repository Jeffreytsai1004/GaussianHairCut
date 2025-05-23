@ECHO OFF
SETLOCAL EnableDelayedExpansion

CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"

ECHO .
ECHO ==========================================================
ECHO    Set environment variables for micromamba and tools
ECHO ==========================================================
SET PROJECT_DIR_ORIGIN=%~dp0
SET PROJECT_DIR=%PROJECT_DIR_ORIGIN:~0,-1%
SET MAMBA_ROOT_PREFIX=%PROJECT_DIR%

SET DATA_PATH=%PROJECT_DIR%\data
SET PKGS_PATH=%PROJECT_DIR%\pkgs
SET ENV_PATH=%PROJECT_DIR%\envs
SET EXT_PATH=%PROJECT_DIR%\ext

SET GDOWN_CACHE=%PROJECT_DIR%\cache\gdown
SET TORCH_HOME=%PROJECT_DIR%\cache\torch
SET HF_HOME=%PROJECT_DIR%\cache\huggingface
SET PYTHONDONTWRITEBYTECODE=1

SET COLMAP_PATH=C:\Program Files\Colmap\bin
SET CMAKE_PATH=C:\Program Files\CMake\bin
SET FFMPEG_PATH=C:\Program Files\FFmpeg\bin
SET BLENDER_PATH=C:\Program Files\Blender Foundation\Blender 3.6
SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
SET VCVARS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build

ECHO .
ECHO ===========================================
ECHO   Clear old cache and environment folders
ECHO ===========================================

ECHO Remove old folders ...
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

ECHO Creating required directories...
FOR %%D IN (
    "Scripts"
    "condabin"
    "cache"
    "data"
    "pkgs"
    "envs"
    "ext"
    "cache\gdown"
    "cache\torch"
    "cache\huggingface"
    "ext\diff_gaussian_rasterization_hair\third_party"
) DO (
    IF NOT EXIST "%%~D" (
        MKDIR "%%~D"
        ECHO Created directory %%~D
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

ECHO .
ECHO ===========================================================
ECHO    Remove old micromamba environments to avoid conflicts
ECHO ===========================================================
ECHO Removing old micromamba environments if present...
CALL "%~dp0micromamba.exe" env list

FOR %%E IN (
    gaussian_splatting_hair
    matte_anything
    openpose
    pixie-env
) DO (
    CALL "%~dp0micromamba.exe" remove -n %%E --yes 2>NUL
)


ECHO.
ECHO ===================================================
ECHO    Installing GaussianSplattingHair Environment
ECHO ===================================================

CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python==3.8 git==2.40.0 git-lfs==3.3.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -y
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CALL python -m pip install --upgrade pip
CALL pip install torch==2.1.0+cu118 torchvision==0.16.0+cu118 torchaudio==2.1.0+cu118 --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir --force-reinstall
CALL pip install -r requirements.txt

ECHO Pulling external libraries...
cd ext
CALL git clone git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1
cd .\openpose
CALL git submodule update --init --recursive --remote
cd ..
CALL git clone https://github.com/hustvl/Matte-Anything
cd .\Matte-Anything
CALL git clone https://github.com/IDEA-Research/GroundingDINO
CALL git clone https://github.com/facebookresearch/segment-anything
CALL git clone https://github.com/facebookresearch/detectron2
cd ..
CALL git clone https://github.com/egorzakharov/NeuralHaircut --recursive
CALL git clone https://github.com/facebookresearch/pytorch3d
cd .\pytorch3d
CALL git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
cd ..
CALL git clone https://github.com/camenduru/simple-knn
cd .\diff_gaussian_rasterization_hair\third_party
CALL git clone git clone https://github.com/g-truc/glm
cd .\glm
CALL git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
cd ..\..\..
CALL git clone https://github.com/NVIDIAGameWorks/kaolin --recursive
cd .\kaolin
CALL git checkout v0.15.0
cd ..
CALL git clone https://github.com/SSL92/hyperIQA
CALL git git clone https://github.com/Jeffreytsai1004/PIXIE
cd .\PIXIE
CALL git clone https://github.com/1adrianb/face-alignment
cd .\face-alignment
CALL git checkout 54623537fd9618ca7c15688fd85aba706ad92b59
CALL pip install -e .
cd ..\..

ECHO Download Neural Haircut files...
cd .\NeuralHaircut
CALL gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
cd ..
cd .\NeuralHaircut\pretrained_models\diffusion_prior
CALL gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
cd ..\..\..
cd .\NeuralHaircut/PIXIE
CALL gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
CALL tar -xvzf pixie_data.tar.gz
CALL rm pixie_data.tar.gz
cd ..\..
cd .\hyperIQA
mkdir .\pretrained
cd .\pretrained
CALL gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
cd ..\..\..\..

ECHO.
ECHO ============================================
ECHO    Installing Matte-Anything Environment
ECHO ============================================

CALL condabin\micromamba.bat deactivate
CALL "%~dp0micromamba.exe" create -n matte_anything python==3.8 git==2.40.0 git-lfs==3.3.0 -c pytorch -c nvidia -c conda-forge -y
CALL condabin\micromamba.bat activate matte_anything
cd .\ext\Matte-Anything
CALL python -m pip install --upgrade pip
CALL pip install torch==2.1.0+cu118 torchvision==0.16.0+cu118 torchaudio==2.1.0+cu118 --index-url https://download.pytorch.org/whl/cu118
CALL pip install gdown tensorboard timm opencv mkl supervision setuptools easydict wget scikit-image gradio fairscale

cd .\segment-anything
CALL pip install -e .
cd ..
cd .\detectron2
CALL pip install -e .
cd ..
cd .\GroundingDINO
CALL pip install -e .
cd ..

ECHO Download Matte-Anything files...
mkdir .\pretrained
cd .\pretrained
wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
wget https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW
cd ..\..\..

ECHO.
ECHO =========================================
ECHO Installing OpenPose Environment and Build
ECHO =========================================

CALL condabin\micromamba.bat deactivate
CALL "%~dp0micromamba.exe" create -n openpose python==3.8 git==2.40.0 git-lfs==3.3.0 cmake=3.20 -c conda-forge -y
CALL condabin\micromamba.bat activate openpose
CALL python -m pip install --upgrade pip
CALL pip install gdown opencv-python opencv-contrib-python
cd .\ext\openpose
gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
tar -xvzf models.tar.gz
rm models.tar.gz
CALL "%VCVARS_DIR%\vcvarsall.bat" x64
mkdir .\build
cd .\build
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release -DBUILD_CUDA=ON ..
cmake --build . --config Release --target INSTALL
cd ..\..\..

ECHO.
ECHO ===================================
ECHO    Installing PIXIE Environment
ECHO ===================================

CALL condabin\micromamba.bat deactivate
CALL "%~dp0micromamba.exe" create -n pixie-env python==3.8 -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -y
CALL condabin\micromamba.bat activate pixie-env
CALL python -m pip install --upgrade pip
CALL pip install torch==2.1.0+cu118 torchvision==0.16.0+cu118 torchaudio==2.1.0+cu118 --index-url https://download.pytorch.org/whl/cu118
CALL pip install gdown fvcore kornia matplotlib pyyaml
cd .\ext\face-alignment
CALL pip install -e .
cd .\ext\PIXIE
CALL fetch_model.bat
cd ..\..\..

ECHO.
ECHO =============================================
ECHO    GaussianHaircut Installation Complete!
ECHO =============================================
ECHO.
ECHO To start, run:
ECHO   run.bat
ECHO.
ECHO If there are issues, please read README.md for troubleshooting.
ECHO.

PAUSE