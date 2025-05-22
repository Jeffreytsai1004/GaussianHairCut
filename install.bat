@ECHO OFF
@SETLOCAL EnableDelayedExpansion

@REM Set basic path
@SET "PROJECT_DIR=%~dp0"
@SET "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
@SET "MAMBA_ROOT_PREFIX=%PROJECT_DIR%"

@REM Create necessary directories
@ECHO.
@ECHO Cleaning old environment...
@IF EXIST "%PROJECT_DIR%\cache" RMDIR /S /Q "%PROJECT_DIR%\cache"
@IF EXIST "%PROJECT_DIR%\condabin" RMDIR /S /Q "%PROJECT_DIR%\condabin"
@IF EXIST "%PROJECT_DIR%\pkgs" RMDIR /S /Q "%PROJECT_DIR%\pkgs"
@IF EXIST "%PROJECT_DIR%\envs" RMDIR /S /Q "%PROJECT_DIR%\envs"
@IF EXIST "%PROJECT_DIR%\Scripts" RMDIR /S /Q "%PROJECT_DIR%\Scripts"
@IF EXIST "%PROJECT_DIR%\ext\hyperIQA" RMDIR /S /Q "%PROJECT_DIR%\ext\hyperIQA"
@IF EXIST "%PROJECT_DIR%\ext\kaolin" RMDIR /S /Q "%PROJECT_DIR%\ext\kaolin"
@IF EXIST "%PROJECT_DIR%\ext\Matte-Anything" RMDIR /S /Q "%PROJECT_DIR%\ext\Matte-Anything"
@IF EXIST "%PROJECT_DIR%\ext\NeuralHaircut" RMDIR /S /Q "%PROJECT_DIR%\ext\NeuralHaircut"
@IF EXIST "%PROJECT_DIR%\ext\face-alignment" RMDIR /S /Q "%PROJECT_DIR%\ext\face-alignment"
@IF EXIST "%PROJECT_DIR%\ext\openpose" RMDIR /S /Q "%PROJECT_DIR%\ext\openpose"
@IF EXIST "%PROJECT_DIR%\ext\PIXIE" RMDIR /S /Q "%PROJECT_DIR%\ext\PIXIE"
@IF EXIST "%PROJECT_DIR%\ext\pytorch3d" RMDIR /S /Q "%PROJECT_DIR%\ext\pytorch3d"
@IF EXIST "%PROJECT_DIR%\ext\simple-knn" RMDIR /S /Q "%PROJECT_DIR%\ext\simple-knn"
@IF NOT EXIST "%PROJECT_DIR%\Scripts" MKDIR "%PROJECT_DIR%\Scripts"
@IF NOT EXIST "%PROJECT_DIR%\condabin" MKDIR "%PROJECT_DIR%\condabin"
@IF NOT EXIST "%PROJECT_DIR%\cache" MKDIR "%PROJECT_DIR%\cache"
@IF NOT EXIST "%PROJECT_DIR%\data" MKDIR "%PROJECT_DIR%\data"
@IF NOT EXIST "%PROJECT_DIR%\pkgs" MKDIR "%PROJECT_DIR%\pkgs"
@IF NOT EXIST "%PROJECT_DIR%\envs" MKDIR "%PROJECT_DIR%\envs"
@IF NOT EXIST "%PROJECT_DIR%\ext" MKDIR "%PROJECT_DIR%\ext"
@IF NOT EXIST "%PROJECT_DIR%\cache\gdown" MKDIR "%PROJECT_DIR%\cache\gdown"
@IF NOT EXIST "%PROJECT_DIR%\cache\torch" MKDIR "%PROJECT_DIR%\cache\torch"
@IF NOT EXIST "%PROJECT_DIR%\cache\huggingface" MKDIR "%PROJECT_DIR%\cache\huggingface"
@ECHO Old path cleaned

@REM Initialize micromamba (use project directory as root)
@CALL micromamba shell init --shell=cmd.exe --prefix=%PROJECT_DIR% --yes
@SET "PATH=%PROJECT_DIR%\Scripts;%PROJECT_DIR%\condabin;%PATH%"
@REM Set paths for micromamba
@SET "MAMBA_PKGS_DIRS=%PROJECT_DIR%\pkgs"
@SET "MAMBA_ENVS_DIRS=%PROJECT_DIR%\envs"
@SET "DATA_PATH=%PROJECT_DIR%\data"
@SET "MAMBA_EXE=%PROJECT_DIR%\micromamba.exe"
@SET "PKGS_PATH=%PROJECT_DIR%\pkgs"
@SET "ENV_PATH=%PROJECT_DIR%\envs"
@SET "EXT_PATH=%PROJECT_DIR%\ext"
@SET "GDOWN_CACHE=%PROJECT_DIR%\cache\gdown"
@SET "TORCH_HOME=%PROJECT_DIR%\cache\torch"
@SET "HF_HOME=%PROJECT_DIR%\cache\huggingface"
@SET "PYTHONDONTWRITEBYTECODE=1"
@REM Set paths for external tools
@SET "COLMAP_PATH=C:\Program Files\Colmap\bin"
@SET "CMAKE_PATH=C:\Program Files\CMake\bin"
@SET "FFMPEG_PATH=C:\Program Files\FFmpeg\bin"
@SET "BLENDER_PATH=C:\Program Files\Blender Foundation\Blender 3.6"
@SET "CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
@SET "VCVARS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build"
@SET "PATH=%PATH%;%PROJECT_DIR%;%VCVARS_DIR%;%CUDA_HOME%;%CMAKE_PATH%;%FFMPEG_PATH%;%BLENDER_PATH%;%COLMAP_PATH%"

@REM Kill any running micromamba processes
@ECHO Killing any running micromamba processes...
@taskkill /F /IM micromamba.exe /T 2>NUL
@taskkill /F /IM conda.exe /T 2>NUL
@taskkill /F /IM python.exe /T 2>NUL
@timeout /t 2 /nobreak >NUL

@REM Clean up lock files
@ECHO Cleaning up lock files...
@IF EXIST "%USERPROFILE%\.conda\pkgs\cache\*.json" DEL /F /Q "%USERPROFILE%\.conda\pkgs\cache\*.json"
@IF EXIST "%USERPROFILE%\.conda\pkgs\cache\*.lock" DEL /F /Q "%USERPROFILE%\.conda\pkgs\cache\*.lock"
@IF EXIST "D:\AI\Anaconda\pkgs\cache\*.json" DEL /F /Q "D:\AI\Anaconda\pkgs\cache\*.json"
@IF EXIST "D:\AI\Anaconda\pkgs\cache\*.lock" DEL /F /Q "D:\AI\Anaconda\pkgs\cache\*.lock"
@IF EXIST "%PROJECT_DIR%\pkgs\cache\*.json" DEL /F /Q "%PROJECT_DIR%\pkgs\cache\*.json"
@IF EXIST "%PROJECT_DIR%\pkgs\cache\*.lock" DEL /F /Q "%PROJECT_DIR%\pkgs\cache\*.lock"

@REM List and clean existing environments
@ECHO Listing existing environments...
@CALL micromamba env list
@ECHO Removing old environments if they exist...
@CALL micromamba remove -n gaussian_splatting_hair --yes 2>NUL
@CALL micromamba remove -n matte_anything --yes 2>NUL
@CALL micromamba remove -n openpose --yes 2>NUL
@CALL micromamba remove -n pixie-env --yes 2>NUL

@ECHO.
@ECHO ===================================
@ECHO  GaussianHaircut Windows Installer
@ECHO ===================================
@ECHO.

@ECHO.
@ECHO Creating gaussian_splatting_hair environment...
@CALL cd %PROJECT_DIR%
@CALL micromamba create -n gaussian_splatting_hair python==3.8 git==2.40.0 git-lfs==3.3.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -y
@CALL micromamba run -n gaussian_splatting_hair python -m pip install --upgrade pip
@CALL micromamba run -n gaussian_splatting_hair pip install gdown --no-cache-dir
@CALL micromamba run -n gaussian_splatting_hair pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir --force-reinstall
@CALL micromamba run -n gaussian_splatting_hair pip install torchdiffeq torchsde --no-deps
@CALL micromamba run -n gaussian_splatting_hair pip install -r requirements.txt --no-cache-dir

@ECHO.
@ECHO Pulling external libraries...
@IF NOT EXIST "%PROJECT_DIR%\ext" MKDIR "%PROJECT_DIR%\ext"
@ECHO 1/8 Cloning OpenPose...
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1 %PROJECT_DIR%\ext\openpose
@CALL cd %PROJECT_DIR%\ext\openpose && git submodule update --init --recursive --remote
@CALL cd %PROJECT_DIR%\ext
@ECHO 2/8 Cloning Matte-Anything...
@CALL git clone https://github.com/hustvl/Matte-Anything %PROJECT_DIR%\ext\Matte-Anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything 
@CALL git clone https://github.com/IDEA-Research/GroundingDINO.git
@CALL cd %PROJECT_DIR%\ext
@ECHO 3/8 Cloning NeuralHaircut...
@CALL git clone https://github.com/egorzakharov/NeuralHaircut --recursive %PROJECT_DIR%\ext\NeuralHaircut
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut
@ECHO 4/8 Cloning PyTorch3D...
@CALL git clone https://github.com/facebookresearch/pytorch3d %PROJECT_DIR%\ext\pytorch3d
@CALL cd %PROJECT_DIR%\ext\pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL cd %PROJECT_DIR%\ext
@ECHO 5/8 Cloning simple-knn...
@CALL git clone https://github.com/camenduru/simple-knn %PROJECT_DIR%\ext\simple-knn
@ECHO 6/8 Cloning GLM...
@CALL git clone https://github.com/g-truc/glm %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm
@CALL cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL cd %PROJECT_DIR%\ext
@ECHO 7/8 Cloning kaolin...
@CALL git clone https://github.com/NVIDIAGameWorks/kaolin --recursive %PROJECT_DIR%\ext\kaolin
@CALL cd %PROJECT_DIR%\ext\kaolin && git checkout v0.15.0
@CALL cd %PROJECT_DIR%\ext
@ECHO 8/8 Cloning hyperIQA...
@CALL git clone https://github.com/SSL92/hyperIQA %PROJECT_DIR%\ext\hyperIQA

@CALL cd %PROJECT_DIR%\ext\pytorch3d
@CALL micromamba run -n gaussian_splatting_hair pip install -e .
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\npbgpp
@CALL micromamba run -n gaussian_splatting_hair pip install -e .
@CALL cd %PROJECT_DIR%\ext\simple-knn
@CALL micromamba run -n gaussian_splatting_hair pip install -e .
@CALL cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair
@CALL micromamba run -n gaussian_splatting_hair pip install -e .
@CALL cd %PROJECT_DIR%\ext\kaolin
@CALL micromamba run -n gaussian_splatting_hair pip install -e .

@ECHO.
@ECHO Downloading Neural Haircut pretrained models...
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut
@CALL micromamba run -n gaussian_splatting_hair gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior
@CALL micromamba run -n gaussian_splatting_hair gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\PIXIE
@CALL micromamba run -n gaussian_splatting_hair gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf 
@CALL tar -xvzf pixie_data.tar.gz ./
@CALL del pixie_data.tar.gz
@CALL cd %PROJECT_DIR%\ext\hyperIQA
@CALL mkdir pretrained
@CALL cd %PROJECT_DIR%\ext\hyperIQA\pretrained
@CALL micromamba run -n gaussian_splatting_hair gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE

@ECHO.
@ECHO Creating matte_anything environment...
@CALL cd %PROJECT_DIR%
@CALL micromamba deactivate
@CALL micromamba create -n matte_anything python==3.8 git==2.40.0 git-lfs==3.3.0 -c pytorch -c nvidia -c conda-forge -y
@CALL micromamba run -n matte_anything python -m pip install --upgrade pip
@CALL micromamba run -n matte_anything pip install gdown --no-cache-dir
@CALL micromamba run -n matte_anything pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir --force-reinstall
@CALL micromamba run -n matte_anything pip install torchdiffeq torchsde --no-deps
@CALL micromamba run -n matte_anything pip install tensorboard timm opencv-python mkl setuptools easydict wget scikit-image gradio fairscale
@CALL cd %PROJECT_DIR%\ext\Matte-Anything
@CALL git clone https://github.com/facebookresearch/segment-anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\segment-anything
@CALL micromamba run -n matte_anything pip install -e .
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\
@CALL git clone https://github.com/facebookresearch/detectron2
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\detectron2
@CALL micromamba run -n matte_anything pip install -e .
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL micromamba run -n matte_anything pip install -e .
@CALL micromamba run -n matte_anything pip install supervision==0.22.0
@CALL if not exist %PROJECT_DIR%\ext\Matte-Anything\pretrained mkdir %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL micromamba run -n matte_anything wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL micromamba run -n matte_anything wget https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL micromamba run -n matte_anything gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

@ECHO.
@ECHO Installing OpenPose...
@ECHO Creating openpose environment...
@CALL cd %PROJECT_DIR%
@CALL micromamba deactivate
@CALL micromamba create -n openpose python==3.8 git==2.40.0 git-lfs==3.3.0 cmake=3.20 -c conda-forge -y
@CALL micromamba run -n openpose pip install gdown --no-cache-dir
@CALL cd %PROJECT_DIR%\ext\openpose
@CALL micromamba run -n openpose gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
@CALL tar -xvzf models.tar.gz
@CALL del models.tar.gz
@CALL git submodule update --init --recursive --remote
@CALL micromamba run -n openpose cmake -S %PROJECT_DIR%\ext\openpose -B %PROJECT_DIR%\ext\openpose\build -DBUILD_PYTHON=true -DUSE_CUDNN=off
@CALL micromamba run -n openpose cmake --build %PROJECT_DIR%\ext\openpose\build --parallel 8

@ECHO.
@ECHO Creating PIXIE virtual environment...
@CALL cd %PROJECT_DIR%
@CALL micromamba deactivate
@CALL micromamba create -n pixie-env python==3.8 git==2.40.0 git-lfs==3.3.0 cmake=3.20 -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -y
@CALL micromamba run -n pixie-env pip install gdown --no-cache-dir
@CALL cd %PROJECT_DIR%\ext
@CALL git clone https://github.com/Jeffreytsai1004/PIXIE
@CALL cd %PROJECT_DIR%\ext\PIXIE
@CALL fetch_model.bat
@CALL cd %PROJECT_DIR%\ext\PIXIE
@CALL micromamba run -n pixie-env pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir --force-reinstall
@CALL micromamba run -n pixie-env pip install torchdiffeq torchsde --no-deps
@CALL micromamba run -n pixie-env pip install fvcore pytorch3d kornia matplotlib
@CALL micromamba run -n pixie-env pip install pyyaml==5.4.1
@CALL git clone https://github.com/1adrianb/face-alignment %PROJECT_DIR%\ext\face-alignment
@CALL cd %PROJECT_DIR%\ext\face-alignment
@CALL git checkout 54623537fd9618ca7c15688fd85aba706ad92b59
@CALL micromamba run -n pixie-env pip install -e .
@CALL cd %PROJECT_DIR%

@ECHO.
@ECHO ===================================
@ECHO  GaussianHaircut Installation Complete!
@ECHO ===================================
@ECHO.
@ECHO To run, use the following command:
@ECHO run.bat
@ECHO.
@ECHO If you encounter any issues, please refer to the README.md file
@ECHO.

@PAUSE
