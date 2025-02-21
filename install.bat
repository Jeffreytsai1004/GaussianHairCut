@echo off
setlocal enabledelayedexpansion

REM Set environment variables
set "PYTHONDONTWRITEBYTECODE=1"
set "GDOWN_CACHE=%PROJECT_DIR%\cache\gdown"
set "TORCH_HOME=%PROJECT_DIR%\cache\torch"
set "HF_HOME=%PROJECT_DIR%\cache\huggingface"

@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL SET PROJECT_DIR="%~dp0"
@CALL SET CUDA_HOME="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6"
@CALL SET VS_DIR="D:\Program Files\Microsoft Visual Studio\2022\Community"
@CALL SET VS_VCVARS="%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat"
@CALL SET PATH=%CUDA_HOME%\bin;%PROJECT_DIR%\condabin;%PATH%

REM Create gaussian_splatting_hair environment
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python=3.9 ^
    pytorch=2.1.1 torchvision=0.16.1 torchaudio=2.1.1 pytorch-cuda=11.8 ^
    cmake=3.28.0 pyhocon=0.3.60 icecream=2.1.3 einops=0.6.0 accelerate=0.18.0 ^
    jsonmerge=1.9.0 easydict=1.9 iopath=0.1.10 tensorboardx=2.6 scikit-image=0.20.0 ^
    fvcore=0.1.5 toml=0.10.2 tqdm=4.66.5 gdown=5.2.0 colmap=3.10 ^
    -c pytorch -c nvidia -c conda-forge -c anaconda -c fvcore -c iopath -c bottler -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%
@CALL python -m pip install --upgrade pip
@CALL python -m pip install pysdf==0.1.9 clean-fid==0.1.35 face-alignment==1.4.1 clip==0.2.0 torchdiffeq==0.2.3 torchsde==0.2.5 resize-right==0.0.2

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
    pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 ^
    opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict scikit-image gradio=3.46.1 ^
    -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate matte_anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\
@CALL git clone https://github.com/facebookresearch/segment-anything.git
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\segment-anything
@CALL python -m pip install -e .
@CALL git clone https://github.com/conansherry/detectron2.git
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\detectron2
@CALL python setup.py build develop
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL python -m pip install -e .
@CALL mkdir %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL copy %PROJECT_DIR%\resource\Matte-Anything\pretrained\sam_vit_h_4b8939.pth %PROJECT_DIR%\ext\Matte-Anything\pretrained\
@CALL copy %PROJECT_DIR%\resource\Matte-Anything\pretrained\ViTMatte_B_DIS.pth %PROJECT_DIR%\ext\Matte-Anything\pretrained\
@CALL copy %PROJECT_DIR%\resource\Matte-Anything\pretrained\groundingdino_swint_ogc.pth %PROJECT_DIR%\ext\Matte-Anything\pretrained\
@CALL cd %PROJECT_DIR%\ext\Matte-Anything

@CALL "%~dp0condabin\micromamba.bat" deactivate

REM Create openpose environment
@CALL cd %PROJECT_DIR%
@CALL git submodule update --init --recursive --remote
@CALL "%~dp0micromamba.exe" create -n openpose cmake=3.20 -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate openpose
@CALL cd %PROJECT_DIR%\ext\openpose
@CALL copy %PROJECT_DIR%\resource\openpose\models.tar.gz %PROJECT_DIR%\ext\openpose\
@CALL mkdir build
@CALL cd build
@CALL CALL %VS_VCVARS%
@CALL cmake .. -G "Visual Studio 17 2022" -A x64 -T host=x64 -DBUILD_PYTHON=true -DUSE_CUDNN=off
@CALL cmake --build . --config Release
@CALL cd %PROJECT_DIR%
@CALL "%~dp0condabin\micromamba.bat" deactivate

REM Create pixie-env environment
@CALL cd %PROJECT_DIR%
@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.8 ^
    pytorch=2.0.0 torchvision torchaudio pytorch-cuda=11.8 fvcore kornia matplotlib ^
    -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate pixie-env
@CALL cd %PROJECT_DIR%\ext\PIXIE\
@CALL copy %PROJECT_DIR%\resource\PIXIE\data\* %PROJECT_DIR%\ext\PIXIE\data
@CALL pip install pytorch3d==0.7.5
@CALL pip install pyyaml==5.4.1
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL cd %PROJECT_DIR%
@CALL "%~dp0condabin\micromamba.bat" deactivate