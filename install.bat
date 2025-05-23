ECHO OFF
SETLOCAL EnableDelayedExpansion

REM Set basic path
SET "PROJECT_DIR=%~dp0"
SET "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
SET "MAMBA_ROOT_PREFIX=%PROJECT_DIR%"

REM =======================================
REM Clear old cache and environment folders
REM =======================================
ECHO.
ECHO Cleaning old environment and cache directories...
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

REM =============================
REM Recreate required directories
REM =============================
ECHO Creating required directories...
FOR %%D IN (
    "%PROJECT_DIR%\Scripts"
    "%PROJECT_DIR%\condabin"
    "%PROJECT_DIR%\cache"
    "%PROJECT_DIR%\data"
    "%PROJECT_DIR%\pkgs"
    "%PROJECT_DIR%\envs"
    "%PROJECT_DIR%\ext"
    "%PROJECT_DIR%\cache\gdown"
    "%PROJECT_DIR%\cache\torch"
    "%PROJECT_DIR%\cache\huggingface"
) DO (
    IF NOT EXIST "%%~D" (
        MKDIR "%%~D"
        ECHO Created directory %%~D
    )
)

REM ==================================================
REM Set environment variables for micromamba and tools
REM ==================================================
ECHO Setting environment variables...
SET "MAMBA_ROOT_PREFIX=%PROJECT_DIR%"
SET "MAMBA_PKGS_DIRS=%PROJECT_DIR%\pkgs"
SET "MAMBA_ENVS_DIRS=%PROJECT_DIR%\envs"
SET "DATA_PATH=%PROJECT_DIR%\data"
SET "PKGS_PATH=%PROJECT_DIR%\pkgs"
SET "ENV_PATH=%PROJECT_DIR%\envs"
SET "EXT_PATH=%PROJECT_DIR%\ext"
SET "GDOWN_CACHE=%PROJECT_DIR%\cache\gdown"
SET "TORCH_HOME=%PROJECT_DIR%\cache\torch"
SET "HF_HOME=%PROJECT_DIR%\cache\huggingface"
SET "PYTHONDONTWRITEBYTECODE=1"

REM Tools paths - adjust if installed in different locations
SET COLMAP_PATH=C:\Program Files\Colmap\bin
SET CMAKE_PATH=C:\Program Files\CMake\bin
SET FFMPEG_PATH=C:\Program Files\FFmpeg\bin
SET BLENDER_PATH=C:\Program Files\Blender Foundation\Blender 3.6
SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
SET VCVARS_DIR=D:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build

REM ============================================================================
REM Kill possible running micromamba, conda, python processes to avoid conflicts
REM ============================================================================
ECHO Killing any running micromamba processes...
taskkill /F /IM micromamba.exe /T 2>NUL
taskkill /F /IM conda.exe /T 2>NUL
taskkill /F /IM python.exe /T 2>NUL
timeout /t 2 /nobreak >NUL

REM ======================================================
REM Clean cache lock and json files, avoid pip lock issues
REM ======================================================
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

REM =====================================================
REM Remove old micromamba environments to avoid conflicts
REM =====================================================
ECHO Removing old micromamba environments if present...
CALL micromamba env list

FOR %%E IN (
    gaussian_splatting_hair
    matte_anything
    openpose
    pixie-env
) DO (
    CALL micromamba remove -n %%E --yes 2>NUL
)

REM ===================================================
REM =========== Installation Process Starts ===========
REM ===================================================


REM ============================================
REM --- GaussianSplattingHair Environment ---
REM ============================================
ECHO.
ECHO ============================================
ECHO Installing GaussianSplattingHair Environment
ECHO ============================================
cd /d "%PROJECT_DIR%"
CALL micromamba create -n gaussian_splatting_hair python==3.8 git==2.40.0 git-lfs==3.3.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -y
CALL micromamba run -n gaussian_splatting_hair python -m pip install --upgrade pip
CALL micromamba run -n gaussian_splatting_hair pip install gdown
CALL micromamba run -n gaussian_splatting_hair pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir --force-reinstall
CALL micromamba run -n gaussian_splatting_hair pip install torchdiffeq torchsde --no-deps
CALL micromamba run -n gaussian_splatting_hair pip install -r requirements.txt

REM --- Clone External Libraries ---
ECHO.
ECHO Pulling external libraries...
IF NOT EXIST "%PROJECT_DIR%\ext" MKDIR "%PROJECT_DIR%\ext"

git clone --depth 1 https://github.com/CMU-Perceptual-Computing-Lab/openpose "%PROJECT_DIR%\ext\openpose"
cd /d "%PROJECT_DIR%\ext\openpose"
git submodule update --init --recursive --remote
cd /d "%PROJECT_DIR%\ext"
git clone https://github.com/hustvl/Matte-Anything %PROJECT_DIR%\ext\Matte-Anything
cd /d "%PROJECT_DIR%\ext\Matte-Anything"
git clone https://github.com/IDEA-Research/GroundingDINO.git
cd /d "%PROJECT_DIR%\ext"
git clone --recursive https://github.com/egorzakharov/NeuralHaircut "%PROJECT_DIR%\ext\NeuralHaircut"
cd /d "%PROJECT_DIR%\ext"
git clone https://github.com/facebookresearch/pytorch3d "%PROJECT_DIR%\ext\pytorch3d"
cd /d "%PROJECT_DIR%\ext\pytorch3d"
git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
cd /d "%PROJECT_DIR%\ext"
git clone https://github.com/camenduru/simple-knn "%PROJECT_DIR%\ext\simple-knn"
IF NOT EXIST "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party" (
    MKDIR "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party"
)
git clone https://github.com/g-truc/glm "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm"
cd /d "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm"
git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
cd /d "%PROJECT_DIR%\ext"
git clone --recursive https://github.com/NVIDIAGameWorks/kaolin "%PROJECT_DIR%\ext\kaolin"
cd /d "%PROJECT_DIR%\ext\kaolin"
git checkout v0.15.0
cd /d "%PROJECT_DIR%\ext"
git clone https://github.com/SSL92/hyperIQA "%PROJECT_DIR%\ext\hyperIQA"

REM --- Install python packages for external libs ---
REM Install pytorch3d
cd /d "%PROJECT_DIR%\ext\pytorch3d"
CALL micromamba run -n gaussian_splatting_hair pip install -e .
REM Install NeuralHaircut
cd /d "%PROJECT_DIR%\ext\NeuralHaircut\npbgpp"
CALL micromamba run -n gaussian_splatting_hair pip install -e .
REM Install simple-knn
cd /d "%PROJECT_DIR%\ext\simple-knn"
CALL micromamba run -n gaussian_splatting_hair pip install -e .
REM Install diff_gaussian_rasterization_hair
IF NOT EXIST "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair" MKDIR "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair"
cd /d "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair"
CALL micromamba run -n gaussian_splatting_hair pip install -e .
REM Install kaolin
cd /d "%PROJECT_DIR%\ext\kaolin"
CALL micromamba run -n gaussian_splatting_hair pip install -e .
REM Install pysdf
ECHO Setting Visual Studio environment variables...
SET "DISTUTILS_USE_SDK=1"
SET "CUB_HOME=%PROJECT_DIR%\ext\kaolin\third_party\cub"
SET "FORCE_CUDA=1"
CALL "%VCVARS_DIR%\vcvarsall.bat" x64
CALL micromamba run -n gaussian_splatting_hair pip install pysdf==0.1.9 --no-cache-dir --use-pep517

REM --- Download pretrained models ---
ECHO Downloading Neural Haircut pretrained models...
cd /d "%PROJECT_DIR%\ext\NeuralHaircut"
CALL micromamba run -n gaussian_splatting_hair gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
cd /d "%PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior"
CALL micromamba run -n gaussian_splatting_hair gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
cd /d "%PROJECT_DIR%\ext\NeuralHaircut\PIXIE"
CALL micromamba run -n gaussian_splatting_hair gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf 
tar -xvzf pixie_data.tar.gz ./
del pixie_data.tar.gz
cd /d "%PROJECT_DIR%\ext\hyperIQA"
IF NOT EXIST "%PROJECT_DIR%\ext\hyperIQA\pretrained" MKDIR "%PROJECT_DIR%\ext\hyperIQA\pretrained"
cd /d "%PROJECT_DIR%\ext\hyperIQA\pretrained"
CALL micromamba run -n gaussian_splatting_hair gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
cd /d "%PROJECT_DIR%"

REM ======================================
REM --- Matte-Anything Environment ---
REM ======================================
ECHO.
ECHO =====================================
ECHO Installing Matte-Anything Environment
ECHO =====================================
CALL micromamba deactivate
CALL micromamba create -n matte_anything python==3.8 git==2.40.0 git-lfs==3.3.0 -c pytorch -c nvidia -c conda-forge -y
CALL micromamba run -n matte_anything python -m pip install --upgrade pip
CALL micromamba run -n matte_anything pip install gdown    
CALL micromamba run -n matte_anything pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir --force-reinstall
CALL micromamba run -n matte_anything pip install torchdiffeq torchsde --no-deps
CALL micromamba run -n matte_anything pip install tensorboard timm opencv-python mkl setuptools easydict wget scikit-image gradio fairscale

REM --- Clone related repos and install editable mode ---
REM Install segment-anything
cd /d "%PROJECT_DIR%\ext\Matte-Anything"
git clone https://github.com/facebookresearch/segment-anything
cd /d "%PROJECT_DIR%\ext\Matte-Anything\segment-anything"
CALL micromamba run -n matte_anything pip install -e .
REM Install detectron2
cd /d "%PROJECT_DIR%\ext\Matte-Anything"
git clone https://github.com/facebookresearch/detectron2
cd /d "%PROJECT_DIR%\ext\Matte-Anything\detectron2"
CALL micromamba run -n matte_anything pip install -e .
REM Install groundingdino
cd /d "%PROJECT_DIR%\ext\Matte-Anything\GroundingDINO"
CALL micromamba run -n matte_anything pip install -e .
REM Install supervision
CALL micromamba run -n matte_anything pip install supervision==0.22.0

REM --- Download pretrained models ---
IF NOT EXIST "%PROJECT_DIR%\ext\Matte-Anything\pretrained" MKDIR "%PROJECT_DIR%\ext\Matte-Anything\pretrained"
cd /d "%PROJECT_DIR%\ext\Matte-Anything\pretrained"
CALL micromamba run -n matte_anything wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
CALL micromamba run -n matte_anything wget https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
CALL micromamba run -n matte_anything gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

REM ==========================================
REM --- OpenPose Environment and Build ---
REM ==========================================
ECHO.
ECHO =========================================
ECHO Installing OpenPose Environment and Build
ECHO =========================================
CALL micromamba deactivate
CALL micromamba create -n openpose python==3.8 git==2.40.0 git-lfs==3.3.0 cmake=3.20 -c conda-forge -y
CALL micromamba run -n openpose pip install gdown

REM --- Download openpose models ---
cd /d "%PROJECT_DIR%\ext\openpose"
CALL micromamba run -n openpose gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
tar -xvzf models.tar.gz
del models.tar.gz

git submodule update --init --recursive --remote

CALL micromamba run -n openpose cmake -S "%PROJECT_DIR%\ext\openpose" -B "%PROJECT_DIR%\ext\openpose\build" -DBUILD_PYTHON=ON -DUSE_CUDNN=OFF
CALL micromamba run -n openpose cmake --build "%PROJECT_DIR%\ext\openpose\build" --parallel 8

REM =============================
REM --- PIXIE Environment ---
REM =============================
ECHO.
ECHO ============================
ECHO Installing PIXIE Environment
ECHO ============================
CALL micromamba deactivate
CALL micromamba create -n pixie-env python==3.8 git==2.40.0 git-lfs==3.3.0 cmake=3.20 -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -y
CALL micromamba run -n pixie-env pip install gdown    

REM --- Download PIXIE models ---
REM --- Clone PIXIE repository ---
cd /d "%PROJECT_DIR%\ext"
git clone https://github.com/Jeffreytsai1004/PIXIE

cd /d "%PROJECT_DIR%\ext\PIXIE"
CALL fetch_model.bat

CALL micromamba run -n pixie-env pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir --force-reinstall
CALL micromamba run -n pixie-env pip install torchdiffeq torchsde --no-deps
CALL micromamba run -n pixie-env pip install fvcore pytorch3d kornia matplotlib
CALL micromamba run -n pixie-env pip install pyyaml==5.4.1

REM Face-alignment for PIXIE
cd /d "%PROJECT_DIR%\ext"
git clone https://github.com/1adrianb/face-alignment "%PROJECT_DIR%\ext\face-alignment"
cd /d "%PROJECT_DIR%\ext\face-alignment"
git checkout 54623537fd9618ca7c15688fd85aba706ad92b59
CALL micromamba run -n pixie-env pip install -e .

cd /d "%PROJECT_DIR%"

REM =====================================
REM Installation Complete Notice
REM =====================================
ECHO.
ECHO ======================================
ECHO GaussianHaircut Installation Complete!
ECHO ======================================
ECHO.
ECHO To start, run:
ECHO   run.bat
ECHO.
ECHO If there are issues, please read README.md for troubleshooting.
ECHO.

PAUSE