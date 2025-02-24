@echo off

@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"

Echo ============= SETTING UP GLOBAL VARIABLES =============
@CALL SET PROJECT_DIR=D:\Dev\AI\Gitea\GaussianHaircut
@CALL SET EXT_DIR=%PROJECT_DIR%\ext
@CALL SET ENV_DIR=%PROJECT_DIR%\envs
@CALL SET RESOURCE_DIR=%PROJECT_DIR%\resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Professional
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%\cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%\cache\torch
@CALL set HF_HOME=%PROJECT_DIR%\cache\huggingface
@CALL SET PATH=%CUDA_HOME%\bin;%PROJECT_DIR%condabin;%PATH%
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

REM 验证 CUDA 设置
@CALL nvcc --version

REM 设置 Visual Studio 环境
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Professional
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL IF EXIST "%VS_VCVARS%" CALL "%VS_VCVARS%"

REM 验证编译器
@CALL WHERE cl.exe

Echo ============= CREATING GAUSSIAN_SPLATTING_HAIR ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python=3.9 ^
    -c pytorch -c nvidia -c conda-forge -c anaconda -c fvcore -c iopath -c bottler -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL SET PATH=%ENV_DIR%\gaussian_splatting_hair\bin;%PATH%
@CALL cd %PROJECT_DIR%
@CALL python -m pip install --upgrade pip
@CALL python -m pip install torch==2.6.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL python -m pip install cmake pyhocon icecream einops accelerate jsonmerge easydict iopath tensorboardx scikit-image gdown face-alignment clip torchdiffeq torchsde resize-right clean-fid

@CALL cd %PROJECT_DIR%
@CALL mkdir %EXT_DIR%
@CALL git clone https://github.com/hustvl/Matte-Anything %EXT_DIR%\Matte-Anything
@CALL git clone https://github.com/IDEA-Research/GroundingDINO.git %EXT_DIR%\Matte-Anything\GroundingDINO
@CALL git clone https://github.com/egorzakharov/NeuralHaircut.git --recursive %EXT_DIR%\NeuralHaircut
@CALL git clone https://github.com/facebookresearch/pytorch3d %EXT_DIR%\pytorch3d -b 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL git clone https://github.com/camenduru/simple-knn %EXT_DIR%\simple-knn
@CALL git clone https://github.com/g-truc/glm %EXT_DIR%\glm -b 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL git clone --recursive https://github.com/NVIDIAGameWorks/kaolin %EXT_DIR%\kaolin -b v0.15.0
@CALL git clone https://github.com/facebookresearch/segment-anything.git %EXT_DIR%\Matte-Anything\segment-anything
@CALL git clone git+https://github.com/facebookresearch/detectron2.git %EXT_DIR%\Matte-Anything\detectron2
@CALL git clone https://github.com/SSL92/hyperIQA %EXT_DIR%\hyperIQA
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose %EXT_DIR%\openpose --depth 1
@CALL git clone https://github.com/yfeng95/PIXIE %EXT_DIR%\PIXIE

@CALL mkdir %EXT_DIR%\Matte-Anything\pretrained\
@CALL mkdir %EXT_DIR%\openpose
@CALL mkdir %EXT_DIR%\PIXIE\data

@CALL python -m pip install %EXT_DIR%\pytorch3d
@CALL python -m pip install %EXT_DIR%\NeuralHaircut\npbgpp
@CALL python -m pip install %EXT_DIR%\simple-knn
@CALL python -m pip install %EXT_DIR%\diff_gaussian_rasterization_hair
@CALL python -m pip install %EXT_DIR%\kaolin

@CALL copy %RESOURCE_DIR%\NeuralHaircut\* %EXT_DIR%\NeuralHaircut\
@CALL copy %RESOURCE_DIR%\Matte-Anything\pretrained\* %EXT_DIR%\Matte-Anything\pretrained\
@CALL copy %RESOURCE_DIR%\Matte-Anything\segment-anything\* %EXT_DIR%\Matte-Anything\segment-anything\
@CALL copy %RESOURCE_DIR%\Matte-Anything\detectron2\* %EXT_DIR%\Matte-Anything\detectron2\
@CALL copy %RESOURCE_DIR%\Matte-Anything\GroundingDINO\* %EXT_DIR%\Matte-Anything\GroundingDINO\
@CALL copy %RESOURCE_DIR%\hyperIQA\* %EXT_DIR%\hyperIQA\
@CALL copy %RESOURCE_DIR%\openpose\* %EXT_DIR%\openpose\
@CALL copy %RESOURCE_DIR%\PIXIE\data\* %EXT_DIR%\PIXIE\data\

Echo ============= CREATING MATTE_ANYTHING ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n matte_anything python=3.9 ^
    -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate matte_anything
@CALL SET PATH=%ENV_DIR%\matte_anything\bin;%PATH%
@CALL cd %EXT_DIR%\Matte-Anything\
@CALL python -m pip install --upgrade pip
@CALL python -m pip install torch==2.6.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL python -m pip install cmake mkl setuptools easydict wget scikit-image gradio fairscale pyside2 future pillow
@CALL cd %EXT_DIR%\Matte-Anything\segment-anything
@CALL pip install -e .
@CALL cd %EXT_DIR%\Matte-Anything\detectron2
@CALL pip install -e .
@CALL cd %EXT_DIR%\Matte-Anything\GroundingDINO
@CALL pip install -e .
@CALL cd %EXT_DIR%\Matte-Anything
@CALL pip install supervision==0.22.0
@CALL cd %PROJECT_DIR%

Echo ============= CREATING OPENPOSE ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n openpose python=3.9 -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate openpose
@CALL python -m pip install ninja cmake
@CALL SET PATH=%ENV_DIR%\openpose\bin;%PATH%
@CALL cd %EXT_DIR%\openpose
@CALL mkdir build
@CALL cd build
@CALL cmake .. ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_PYTHON=true ^
    -DUSE_CUDNN=off ^
    -DCUDA_TOOLKIT_ROOT_DIR="%CUDA_HOME%" ^
    -DCUDA_BIN_PATH="%CUDA_HOME%\bin" ^
    -DCUDA_INCLUDE_DIRS="%CUDA_HOME%\include" ^
    -DCUDA_CUDART_LIBRARY="%CUDA_HOME%\lib\x64\cudart.lib" ^
    -DPython3_ROOT_DIR="%ENV_DIR%\openpose"
@CALL ninja
@CALL cd %PROJECT_DIR%

Echo ============= CREATING PIXIE-ENV ENVIRONMENT =============
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.9 -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate pixie-env
@CALL SET PATH=%ENV_DIR%\pixie-env\bin;%PATH%
@CALL cd %EXT_DIR%\PIXIE
@CALL python -m pip install --upgrade pip
@CALL pip install torch==2.6.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL pip install fvcore kornia matplotlib pytorch3d pyyaml
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL cd %PROJECT_DIR%



























