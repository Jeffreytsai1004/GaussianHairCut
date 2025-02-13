@echo off
SET MICROMAMBA_EXE=%~dp0micromamba.exe
SET MAMBA_ROOT_PREFIX=%~dp0micromamba
SET CUDA_HOME="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
SET PATH=%CUDA_HOME%\bin;%PATH%
SET PROJECT_DIR=%~dp0
SET PYTHONDONTWRITEBYTECODE=1
SET TORCH_HOME=%PROJECT_DIR%\cache\torch
SET HF_HOME=%PROJECT_DIR%\cache\huggingface
SET GDOWN_CACHE=%PROJECT_DIR%\cache\gdown
SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6"
SET VS2019_DIR="C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools"
SET VS2019_VCVARS="%VS2019_DIR%\VC\Auxiliary\Build\vcvars64.bat"

CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\pixie-env
