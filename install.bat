@echo off

@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"

Echo ============= SETTING UP GLOBAL VARIABLES =============
@CALL SET PROJECT_DIR=%~dp0
@CALL SET EXT_DIR=%PROJECT_DIR%ext
@CALL SET ENV_DIR=%PROJECT_DIR%envs
@CALL SET RESOURCE_DIR=%PROJECT_DIR%resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET NVCC_PATH=%CUDA_HOME%\bin\nvcc.exe
@CALL SET CUDA_DIR=%CUDA_HOME%
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%cache\torch
@CALL set HF_HOME=%PROJECT_DIR%cache\huggingface
Echo CUDA_HOME: %CUDA_HOME%
Echo CUDA_DIR: %CUDA_DIR%
Echo PROJECT_DIR: %PROJECT_DIR%
Echo EXT_DIR: %EXT_DIR%
Echo ENV_DIR: %ENV_DIR%
Echo RESOURCE_DIR: %RESOURCE_DIR%
Echo BLENDER_DIR: %BLENDER_DIR%
Echo VS_DIR: %VS_DIR%
Echo VS_VCVARS: %VS_VCVARS%
Echo GDOWN_CACHE: %GDOWN_CACHE%
Echo TORCH_HOME: %TORCH_HOME%
Echo HF_HOME: %HF_HOME%
@CALL SET PATH=%CUDA_HOME%\bin;%PROJECT_DIR%condabin;%PATH%

Echo ============= CREATING GAUSSIAN_SPLATTING_HAIR ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python=3.9 ^
    -c pytorch -c nvidia -c conda-forge -c anaconda -c fvcore -c iopath -c bottler -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL SET PROJECT_DIR=%~dp0
@CALL SET EXT_DIR=%PROJECT_DIR%ext
@CALL SET ENV_DIR=%PROJECT_DIR%envs
@CALL SET RESOURCE_DIR=%PROJECT_DIR%resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET NVCC_PATH=%CUDA_HOME%\bin\nvcc.exe
@CALL SET CUDA_DIR=%CUDA_HOME%
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%cache\torch
@CALL set HF_HOME=%PROJECT_DIR%cache\huggingface
Echo CUDA_HOME: %CUDA_HOME%
Echo CUDA_DIR: %CUDA_DIR%
Echo PROJECT_DIR: %PROJECT_DIR%
Echo EXT_DIR: %EXT_DIR%
Echo ENV_DIR: %ENV_DIR%
Echo RESOURCE_DIR: %RESOURCE_DIR%
Echo BLENDER_DIR: %BLENDER_DIR%
Echo VS_DIR: %VS_DIR%
Echo VS_VCVARS: %VS_VCVARS%
Echo GDOWN_CACHE: %GDOWN_CACHE%
Echo TORCH_HOME: %TORCH_HOME%
Echo HF_HOME: %HF_HOME%
@CALL SET PATH=%CUDA_HOME%\bin;%ENV_DIR%\gaussian_splatting_hair\bin;%PROJECT_DIR%condabin;%PATH%
@CALL cd %PROJECT_DIR%
@CALL python -m pip install --upgrade pip
@CALL python -m pip install torch==2.6.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL python -m pip install cmake pyhocon icecream einops accelerate jsonmerge easydict iopath tensorboardx scikit-image gdown face-alignment clip torchdiffeq torchsde resize-right clean-fid pyside2 future

@CALL cd %PROJECT_DIR%
@CALL mkdir ext
@CALL git clone https://github.com/hustvl/Matte-Anything .\ext\Matte-Anything
@CALL git clone https://github.com/IDEA-Research/GroundingDINO.git .\ext\Matte-Anything\GroundingDINO
@CALL git clone https://github.com/egorzakharov/NeuralHaircut.git --recursive .\ext\NeuralHaircut
@CALL git clone https://github.com/facebookresearch/pytorch3d .\ext\pytorch3d
@CALL cd ext\pytorch3d
@CALL git switch -c 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL cd %PROJECT_DIR%
@CALL git clone https://github.com/camenduru/simple-knn .\ext\simple-knn
@CALL git clone https://github.com/g-truc/glm .\ext\glm -b 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL git clone --recursive https://github.com/NVIDIAGameWorks/kaolin .\ext\kaolin -b v0.15.0
@CALL git clone https://github.com/facebookresearch/segment-anything.git .\ext\Matte-Anything\segment-anything
@CALL git clone https://github.com/facebookresearch/detectron2.git .\ext\Matte-Anything\detectron2
@CALL git clone https://github.com/SSL92/hyperIQA .\ext\hyperIQA
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose .\ext\openpose --depth 1
@CALL git clone https://github.com/yfeng95/PIXIE .\ext\PIXIE

@CALL mkdir .\ext\Matte-Anything\pretrained\
@CALL mkdir .\ext\openpose
@CALL mkdir .\ext\PIXIE\data

@CALL python -m pip install .\ext\NeuralHaircut\npbgpp
@CALL python -m pip install .\ext\simple-knn
@CALL python -m pip install .\ext\diff_gaussian_rasterization_hair
@CALL python -m pip install .\ext\kaolin

@CALL copy %RESOURCE_DIR%\NeuralHaircut\* .\ext\NeuralHaircut\
@CALL copy %RESOURCE_DIR%\Matte-Anything\pretrained\* .\ext\Matte-Anything\pretrained\
@CALL copy %RESOURCE_DIR%\Matte-Anything\segment-anything\* .\ext\Matte-Anything\segment-anything\
@CALL copy %RESOURCE_DIR%\Matte-Anything\detectron2\* .\ext\Matte-Anything\detectron2\
@CALL copy %RESOURCE_DIR%\Matte-Anything\GroundingDINO\* .\ext\Matte-Anything\GroundingDINO\
@CALL copy %RESOURCE_DIR%\hyperIQA\* .\ext\hyperIQA\
@CALL copy %RESOURCE_DIR%\openpose\* .\ext\openpose\
@CALL copy %RESOURCE_DIR%\PIXIE\data\* .\ext\PIXIE\data\

Echo ============= CREATING MATTE_ANYTHING ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n matte_anything python=3.9 ^
    -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate matte_anything
@CALL SET PROJECT_DIR=%~dp0
@CALL SET EXT_DIR=%PROJECT_DIR%ext
@CALL SET ENV_DIR=%PROJECT_DIR%envs
@CALL SET RESOURCE_DIR=%PROJECT_DIR%resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET NVCC_PATH=%CUDA_HOME%\bin\nvcc.exe
@CALL SET CUDA_DIR=%CUDA_HOME%
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%cache\torch
@CALL set HF_HOME=%PROJECT_DIR%cache\huggingface
Echo CUDA_HOME: %CUDA_HOME%
Echo CUDA_DIR: %CUDA_DIR%
Echo PROJECT_DIR: %PROJECT_DIR%
Echo EXT_DIR: %EXT_DIR%
Echo ENV_DIR: %ENV_DIR%
Echo RESOURCE_DIR: %RESOURCE_DIR%
Echo BLENDER_DIR: %BLENDER_DIR%
Echo VS_DIR: %VS_DIR%
Echo VS_VCVARS: %VS_VCVARS%
Echo GDOWN_CACHE: %GDOWN_CACHE%
Echo TORCH_HOME: %TORCH_HOME%
Echo HF_HOME: %HF_HOME%
@CALL SET PATH=%CUDA_HOME%\bin;%ENV_DIR%\matte_anything\bin;%PROJECT_DIR%condabin;%PATH%
@CALL cd %PROJECT_DIR%
@CALL cd ext\Matte-Anything\
@CALL python -m pip install --upgrade pip
@CALL python -m pip install torch==2.6.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL python -m pip install cmake mkl setuptools easydict wget scikit-image gradio fairscale pyside2 future pillow typing-extensions filelock
@CALL python -m pip install ninja
@CALL cd ext\Matte-Anything\segment-anything
@CALL python -m pip install -e . --global-option="build_ext" --global-option="-j4"
@CALL cd ext\Matte-Anything\detectron2
@CALL python -m pip install -e . --global-option="build_ext" --global-option="-j4"
@CALL cd ext\Matte-Anything\GroundingDINO
@CALL python -m pip install -e . --global-option="build_ext" --global-option="-j4"
@CALL cd ext\Matte-Anything
@CALL python -m pip install supervision==0.22.0
@CALL cd %PROJECT_DIR%

Echo ============= CREATING OPENPOSE ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n openpose python=3.9 -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate openpose
@CALL SET PROJECT_DIR=%~dp0
@CALL SET EXT_DIR=%PROJECT_DIR%ext
@CALL SET ENV_DIR=%PROJECT_DIR%envs
@CALL SET RESOURCE_DIR=%PROJECT_DIR%resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET NVCC_PATH=%CUDA_HOME%\bin\nvcc.exe
@CALL SET CUDA_DIR=%CUDA_HOME%
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%cache\torch
@CALL set HF_HOME=%PROJECT_DIR%cache\huggingface
Echo CUDA_HOME: %CUDA_HOME%
Echo CUDA_DIR: %CUDA_DIR%
Echo PROJECT_DIR: %PROJECT_DIR%
Echo EXT_DIR: %EXT_DIR%
Echo ENV_DIR: %ENV_DIR%
Echo RESOURCE_DIR: %RESOURCE_DIR%
Echo BLENDER_DIR: %BLENDER_DIR%
Echo VS_DIR: %VS_DIR%
Echo VS_VCVARS: %VS_VCVARS%
Echo GDOWN_CACHE: %GDOWN_CACHE%
Echo TORCH_HOME: %TORCH_HOME%
Echo HF_HOME: %HF_HOME%
@CALL SET PATH=%CUDA_HOME%\bin;%ENV_DIR%\openpose\bin;%PROJECT_DIR%condabin;%PATH%
@CALL cd ext\openpose

REM 设置 CUDA 编译器标志，允许使用不支持的编译器版本
@CALL SET NVCC_FLAGS=-allow-unsupported-compiler

REM 手动下载依赖文件
@CALL mkdir 3rdparty\windows
@CALL cd 3rdparty\windows
@CALL curl -L -o caffe3rdparty_16_2020_11_14.zip http://vcl.snu.ac.kr/OpenPose/3rdparty/windows/caffe3rdparty_16_2020_11_14.zip
@CALL curl -L -o caffe_16_2020_11_14.zip http://vcl.snu.ac.kr/OpenPose/3rdparty/windows/caffe_16_2020_11_14.zip
@CALL cd ..\..

REM 配置 CMake 时添加 CUDA 编译器标志
@CALL cmake -G "Visual Studio 17 2022" -A x64 ^
    -DCUDA_NVCC_FLAGS="-allow-unsupported-compiler" ^
    -DBUILD_PYTHON=ON ^
    -DDOWNLOAD_BODY_25_MODEL=ON ^
    -DDOWNLOAD_BODY_MPI_MODEL=OFF ^
    -DDOWNLOAD_HAND_MODEL=OFF ^
    -DDOWNLOAD_FACE_MODEL=OFF ^
    .

@CALL cmake --build . --config Release

@CALL cd %PROJECT_DIR%

Echo ============= CREATING PIXIE-ENV ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.9 -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate pixie-env
@CALL SET PROJECT_DIR=%~dp0
@CALL SET EXT_DIR=%PROJECT_DIR%ext
@CALL SET ENV_DIR=%PROJECT_DIR%envs
@CALL SET RESOURCE_DIR=%PROJECT_DIR%resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET NVCC_PATH=%CUDA_HOME%\bin\nvcc.exe
@CALL SET CUDA_DIR=%CUDA_HOME%
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%cache\torch
@CALL set HF_HOME=%PROJECT_DIR%cache\huggingface
Echo CUDA_HOME: %CUDA_HOME%
Echo CUDA_DIR: %CUDA_DIR%
Echo PROJECT_DIR: %PROJECT_DIR%
Echo EXT_DIR: %EXT_DIR%
Echo ENV_DIR: %ENV_DIR%
Echo RESOURCE_DIR: %RESOURCE_DIR%
Echo BLENDER_DIR: %BLENDER_DIR%
Echo VS_DIR: %VS_DIR%
Echo VS_VCVARS: %VS_VCVARS%
Echo GDOWN_CACHE: %GDOWN_CACHE%
Echo TORCH_HOME: %TORCH_HOME%
Echo HF_HOME: %HF_HOME%
@CALL SET PATH=%CUDA_HOME%\bin;%ENV_DIR%\pixie-env\bin;%PROJECT_DIR%condabin;%PATH%
@CALL cd ext\PIXIE
@CALL python -m pip install --upgrade pip
@CALL pip install torch==2.6.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL pip install fvcore kornia matplotlib pyyaml
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL git clone https://github.com/facebookresearch/pytorch3d.git ext\pytorch3d
@CALL cd ext\pytorch3d
@CALL git switch -c 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL pip install -e .
@CALL cd %PROJECT_DIR%



























