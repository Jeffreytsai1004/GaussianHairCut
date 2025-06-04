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
SET ROOT_PREFIX=%PROJECT_DIR%
SET DATA_PATH=%PROJECT_DIR%\data
SET PKGS_PATH=%PROJECT_DIR%\pkgs
SET ENV_PATH=%PROJECT_DIR%\envs
SET EXT_PATH=%PROJECT_DIR%\ext
SET GDOWN_CACHE=%PROJECT_DIR%\cache\gdown
SET TORCH_HOME=%PROJECT_DIR%\cache\torch
SET HF_HOME=%PROJECT_DIR%\cache\huggingface
SET PYTHONDONTWRITEBYTECODE=1
SET PYTORCH3D_NO_NINJA=1
SET DISTUTILS_USE_SDK=1
SET MSSdk=1
SET "COLMAP_PATH=C:\Program Files\Colmap\bin"
SET "CMAKE_PATH=C:\Program Files\CMake\bin"
SET "FFMPEG_PATH=C:\Program Files\FFmpeg\bin"
SET "BLENDER_PATH=C:\Program Files\Blender Foundation\Blender 3.6"
SET "CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
SET "VCVARS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build"
SET "CUB_HOME=C:\Program Files\cub"
SET "CUDA_PATH=%CUDA_HOME%"
SET "PATH=%PROJECT_DIR%;%PATH%"
SET "PATH=%PATH%;%CUDA_PATH%\bin"

ECHO .
ECHO ==========================================================
ECHO    Micromamba Base Info
ECHO ==========================================================
ECHO .
ECHO micromamba config list:
CALL "%~dp0micromamba.exe" config list
ECHO micromamba info:
CALL "%~dp0micromamba.exe" info

ECHO .
ECHO ===========================================
ECHO Clear old cache and environment folders
ECHO ===========================================

ECHO Remove old folders ...
FOR %%D IN (
    "cache"
    "condabin"
    "envs"
    "Scripts"
    "ext\openpose"
    "ext\Matte-Anything"
    "ext\NeuralHaircut"
    "ext\simple-knn"
    "ext\diff_gaussian_rasterization_hair\third_party\glm"
    "ext\hyperIQA"
    "ext\kaolin"
    "ext\PIXIE"
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
taskkill /F /IM pip /T 2>NUL
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

# Search and remove broken packages
cd %USERPROFILE%\AppData\Roaming\Python\Python39\site-packages
dir *-info
# Remove all directories ending with "-info"
FOR %%D IN (*-info) DO (
    IF EXIST "%%~D" (
        ECHO Removing directory %%~D...
        RMDIR /S /Q "%%~D"
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
cd "%ROOT_PREFIX%"
CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python==3.8 git git-lfs eigen -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -y
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair python -m pip install --upgrade pip
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install torch==2.1.0+cu118 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install opencv-python opencv-contrib-python libpython matplotlib plotly flake8 flake8-bugbear flake8-comprehensions pyyaml tensorboard scipy trimesh future pybind11 imageio pycocotools numpy 
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install setuptools plyfile cmake pyhocon icecream einops accelerate jsonmerge easydict iopath ^
    tensorboardx scikit-image fvcore toml tqdm gdown clean-fid face-alignment torchdiffeq torchsde resize-right

ECHO Pulling external libraries...
cd "%PROJECT_DIR%\ext"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1  %PROJECT_DIR%\ext\openpose
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/hustvl/Matte-Anything %PROJECT_DIR%\ext\Matte-Anything
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/IDEA-Research/GroundingDINO %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/facebookresearch/detectron2 %PROJECT_DIR%\ext\Matte-Anything\detectron2
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/egorzakharov/NeuralHaircut --recursive %PROJECT_DIR%\ext\NeuralHaircut
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/facebookresearch/pytorch3d %PROJECT_DIR%\ext\pytorch3d
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/camenduru/simple-knn %PROJECT_DIR%\ext\simple-knn
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/g-truc/glm %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/NVIDIAGameWorks/kaolin --recursive %PROJECT_DIR%\ext\kaolin
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/SSL92/hyperIQA %PROJECT_DIR%\ext\hyperIQA
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git clone https://github.com/Jeffreytsai1004/PIXIE %PROJECT_DIR%\ext\PIXIE

cd "%PROJECT_DIR%\ext\openpose"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git submodule update --init --recursive --remote
@REM cd "%PROJECT_DIR%\ext\pytorch3d"
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
cd "%PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
cd "%PROJECT_DIR%\ext\kaolin"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair git checkout v0.15.0

ECHO.
cd "%PROJECT_DIR%"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install glm simple-knn kaolin
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install -e "%PROJECT_DIR%\ext\pytorch3d"
cd "%PROJECT_DIR%\ext\pytorch3d"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install -e .
cd "%PROJECT_DIR%\ext"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install -e "%PROJECT_DIR%\ext\NeuralHaircut\npbgpp"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install -e "%PROJECT_DIR%\diff_gaussian_rasterization_hair"
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install -e pysdf
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install -e "%PROJECT_DIR%\ext\simple-knn"
@REM CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair pip install -e "%PROJECT_DIR%\ext\kaolin"

cd "%PROJECT_DIR%"

ECHO Download Neural Haircut files...
cd "%PROJECT_DIR%\ext\NeuralHaircut
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
cd "%PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
cd "%PROJECT_DIR%\ext\NeuralHaircut\PIXIE
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
tar -xvzf pixie_data.tar.gz
rm pixie_data.tar.gz
mkdir %PROJECT_DIR%\ext\hyperIQA\pretrained
cd "%PROJECT_DIR%\ext\hyperIQA\pretrained
CALL "%~dp0micromamba.exe" run -n gaussian_splatting_hair gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
cd "%PROJECT_DIR%

ECHO.
ECHO ============================================
ECHO    Installing Matte-Anything Environment
ECHO ============================================
cd "%ROOT_PREFIX%"
CALL "%~dp0micromamba.exe" create -n matte_anything python==3.8 git==2.40.0 git-lfs==3.3.0 ninja -c pytorch -c nvidia -c conda-forge -c fvcore -y
cd "%PROJECT_DIR%\ext\Matte-Anything"
CALL "%~dp0micromamba.exe" run -n matte_anything python -m pip install --upgrade pip
CALL "%~dp0micromamba.exe" run -n matte_anything pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
CALL "%~dp0micromamba.exe" run -n matte_anything pip install setuptools wheel opencv-python opencv-contrib-python libpython matplotlib pycocotools-windows numpy pybind11 fvcore tensorboard tensorboardx ^
    gdown timm mkl supervision easydict wget scikit-image gradio fairscale catkin_pkg segment-anything

Echo Install Matte-Anything requirements...
cd "%PROJECT_DIR%\ext\Matte-Anything\GroundingDINO"
CALL "%~dp0micromamba.exe" run -n matte_anything pip install -e .
cd "%PROJECT_DIR%\ext\Matte-Anything\detectron2"
CALL "%~dp0micromamba.exe" run -n matte_anything pip install setuptools wheel --upgrade
CALL "%~dp0micromamba.exe" run -n matte_anything pip install -e .

ECHO Download Matte-Anything files...
mkdir "%PROJECT_DIR%\ext\Matte-Anything\pretrained"
cd "%PROJECT_DIR%\ext\Matte-Anything\pretrained"
@REM wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@REM wget https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@REM CALL "%~dp0micromamba.exe" run -n matte_anything gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW
cd "%PROJECT_DIR%\ext\Matte-Anything"

ECHO.
ECHO =========================================
ECHO Installing OpenPose Environment and Build
ECHO =========================================
cd "%ROOT_PREFIX%"
CALL "%~dp0micromamba.exe" create -n openpose python==3.8 git==2.40.0 git-lfs==3.3.0 cmake=3.20 -c conda-forge -y
CALL "%~dp0micromamba.exe" run -n openpose python -m pip install --upgrade pip
CALL "%~dp0micromamba.exe" run -n openpose pip install gdown setuptools opencv-python opencv-contrib-python libpython matplotlib pycocotools-windows numpy pybind11 fvcore tensorboard tensorboardx scikit-image scipy tqdm
cd "%PROJECT_DIR%\ext\openpose"

@REM ECHO Download OpenPose models...
@REM CALL "%~dp0micromamba.exe" run -n openpose gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
@REM tar -xvzf models.tar.gz
@REM rm models.tar.gz

@REM ECHO Build openpose...
@REM mkdir "%PROJECT_DIR%\ext\openpose\build"
@REM cd "%PROJECT_DIR%\ext\openpose\build"
@REM CALL "%~dp0micromamba.exe" run -n openpose cmake .. -G "Visual Studio 17 2022" -A x64 -T v143
@REM CALL "%~dp0micromamba.exe" run -n openpose cmake --build . --config Release
@REM mkdir "%PROJECT_DIR%\ext\openpose\bin"
@REM xcopy /Y /S /I "%PROJECT_DIR%\ext\openpose\build\bin\x64\Release\*" "%PROJECT_DIR%\ext\openpose\bin"

ECHO.
ECHO ===================================
ECHO    Installing PIXIE Environment
ECHO ===================================
cd "%ROOT_PREFIX%"
CALL "%~dp0micromamba.exe" create -n pixie-env python=3.8 -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -y
CALL "%~dp0micromamba.exe" run -n pixie-env python -m pip install --upgrade pip
CALL "%~dp0micromamba.exe" run -n pixie-env pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
CALL "%~dp0micromamba.exe" run -n pixie-env pip install gdown fvcore kornia matplotlib pyyaml face-alignment
cd "%PROJECT_DIR%\ext\pytorch3d"
CALL "%~dp0micromamba.exe" run -n pixie-env pip install -e .
cd "%PROJECT_DIR%\ext\PIXIE"
@REM CALL "%~dp0micromamba.exe" run -n pixie-env fetch_model.bat
cd "%PROJECT_DIR%"

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