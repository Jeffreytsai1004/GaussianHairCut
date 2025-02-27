@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
start cmd /k "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL SET PROJECT_DIR=%~dp0
@CALL SET RESOURCE_DIR=%PROJECT_DIR%resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET NVCC_PATH=%CUDA_HOME%\bin\nvcc.exe
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL SET DATA_PATH=%PROJECT_DIR%raw
@CALL SET EXT_DIR=%PROJECT_DIR%ext
@CALL SET ENV_DIR=%PROJECT_DIR%envs
@CALL SET CUDA_DIR=%CUDA_HOME%
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%cache\torch
@CALL set HF_HOME=%PROJECT_DIR%cache\huggingface
Echo PROJECT_DIR: %PROJECT_DIR%
Echo BLENDER_DIR: %BLENDER_DIR%
Echo DATA_PATH: %DATA_PATH%
Echo CUDA_HOME: %CUDA_HOME%
Echo CUDA_DIR: %CUDA_DIR%
Echo ENV_DIR: %ENV_DIR%
Echo EXT_DIR: %EXT_DIR%
Echo RESOURCE_DIR: %RESOURCE_DIR%
Echo VS_DIR: %VS_DIR%
Echo VS_VCVARS: %VS_VCVARS%
Echo GDOWN_CACHE: %GDOWN_CACHE%
Echo TORCH_HOME: %TORCH_HOME%
Echo HF_HOME: %HF_HOME%
@CALL SET PATH=%CUDA_HOME%\bin;%ENV_DIR%\gaussian_splatting_hair\bin;%PROJECT_DIR%condabin;%PATH%