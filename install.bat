@echo off
setlocal enabledelayedexpansion

REM Set environment variables
@CALL set "PYTHONDONTWRITEBYTECODE=1"
@CALL set "GDOWN_CACHE=%~dp0\cache\gdown"
@CALL set "TORCH_HOME=%~dp0\cache\torch"
@CALL set "HF_HOME=%~dp0\cache\huggingface"

@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL SET PROJECT_DIR=%~dp0
@CALL SET CUDA_HOME="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6"
@CALL SET VS_DIR="C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools"
@CALL SET VS_VCVARS="%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat"
@CALL SET PATH=%CUDA_HOME%\bin;%PROJECT_DIR%\condabin;%PATH%

REM Create gaussian_splatting_hair environment
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python=3.9 ^
    -c pytorch -c nvidia -c conda-forge -c anaconda -c fvcore -c iopath -c bottler -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%
@CALL python -m pip install --upgrade pip
@CALL python -m pip install torch==2.1.1+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL python -m pip install cmake pyhocon icecream einops accelerate jsonmerge easydict iopath tensorboardx scikit-image gdown colmap --force-reinstall --no-cache-dir
@CALL python -m pip install pysdf clean-fid face-alignment clip torchdiffeq torchsde resize-right


REM Clone repositories
@CALL cd %PROJECT_DIR%
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose %PROJECT_DIR%\ext\openpose --depth 1
@CALL cd %PROJECT_DIR%\ext\openpose && git submodule update --init --recursive --remote
@CALL cd %PROJECT_DIR%
@CALL git clone https://github.com/hustvl/Matte-Anything %PROJECT_DIR%\ext\Matte-Anything
@CALL git clone https://github.com/IDEA-Research/GroundingDINO.git %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL git clone https://github.com/egorzakharov/NeuralHaircut.git --recursive %PROJECT_DIR%\ext\NeuralHaircut
@CALL git clone https://github.com/facebookresearch/pytorch3d %PROJECT_DIR%\ext\pytorch3d
@CALL cd %PROJECT_DIR%\ext\pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL cd %PROJECT_DIR%
@CALL git clone https://github.com/camenduru/simple-knn %PROJECT_DIR%\ext\simple-knn
@CALL git clone https://github.com/g-truc/glm %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm
@CALL cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL cd %PROJECT_DIR%
@CALL git clone https://github.com/SSL92/hyperIQA %PROJECT_DIR%\ext\hyperIQA
@CALL cd %PROJECT_DIR%

REM Download Neural Haircut files
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut
@CALL python -m gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior
@CALL python -m gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\PIXIE
@CALL python -m gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
@CALL tar -xvzf pixie_data.tar.gz
@CALL del /f /q pixie_data.tar.gz
@CALL cd %PROJECT_DIR%\ext\hyperIQA
@CALL mkdir pretrained
@CALL cd pretrained
@CALL python -m gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
@CALL cd %PROJECT_DIR%

@CALL "%~dp0condabin\micromamba.bat" deactivate

REM Create matte_anything environment
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n matte_anything python=3.9 ^
    -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate matte_anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\
@CALL python -m pip install --upgrade pip
@CALL python -m pip install torch==2.1.1+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL python -m pip install mkl easydict wget scikit-image gradio fairscale pyside2 future pillow setuptools future --force-reinstall --no-cache-dir
@CALL git clone https://github.com/facebookresearch/segment-anything.git %PROJECT_DIR%\ext\Matte-Anything\segment-anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\segment-anything
@CALL python -m pip install -e .
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\
@CALL git clone https://github.com/conansherry/detectron2.git %PROJECT_DIR%\ext\Matte-Anything\detectron2
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\detectron2
@CALL python setup.py build develop
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL python -m pip install -e .
@CALL mkdir %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL curl -L -o sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL curl -L -o groundingdino_swint_ogc.pth https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL "%~dp0condabin\micromamba.bat" deactivate
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL python -m gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

REM Create openpose environment
@CALL cd %PROJECT_DIR%ext\openpose
@CALL python -m gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
@CALL tar -xvzf models.tar.gz
@CALL git submodule update --init --recursive --remote
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -y -n openpose python=3.9 cmake=3.20 opencv=4.5.3 -c conda-forge -r "%~dp0\"
@CALL "%~dp0condabin\micromamba.bat" activate openpose
@CALL cd %PROJECT_DIR%ext\openpose
@CALL rmdir /s /q build 2>nul
@CALL del /f /q CMakeCache.txt 2>nul
@CALL rmdir /s /q CMakeFiles 2>nul
@CALL mkdir build
@CALL cd %PROJECT_DIR%ext\openpose\build
@CALL cmake %PROJECT_DIR%ext\openpose -G "Visual Studio 16 2019" -A x64 -T host=x64
@CALL cmake --build . --config Release
@CALL cd %PROJECT_DIR%
@CALL "%~dp0condabin\micromamba.bat" deactivate

REM Create pixie-env environment
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.8 ^
    -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate pixie-env
@CALL cd %PROJECT_DIR%\ext\PIXIE\
@CALL python -m pip install --upgrade pip
@CALL python -m pip install torch==2.1.1+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall --no-cache-dir
@CALL python -m fvcore kornia matplotlib pytorch3d pyyaml
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL cd %PROJECT_DIR%
@CALL "%~dp0condabin\micromamba.bat" deactivate