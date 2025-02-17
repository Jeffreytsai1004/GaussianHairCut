@echo off

REM 设置环境变量
SET CUDA_HOME="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
SET PATH="%CUDA_HOME%\bin;%PATH%"
SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6"
SET VS_DIR="C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools"
SET VS_VCVARS="%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat"
SET PROJECT_DIR=%~dp0
SET MICROMAMBA_EXE=%~dp0micromamba.exe
SET MAMBA_ROOT_PREFIX=%PROJECT_DIR%\micromamba
SET PYTHONDONTWRITEBYTECODE=1
SET GDOWN_CACHE=cache\gdown
SET TORCH_HOME=cache\torch
SET HF_HOME=cache\huggingface

CALL %MICROMAMBA_EXE% activate -p %MAMBA_ROOT_PREFIX%\envs\openpose
IF EXIST %VS_VCVARS% CALL %VS_VCVARS%