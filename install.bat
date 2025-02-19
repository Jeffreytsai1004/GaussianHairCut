@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL SET PROJECT_DIR=%~dp0
@CALL SET CUDA_HOME="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\"
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET VS_DIR="C:\Program Files\Microsoft Visual Studio\2022\Professional\"
@CALL SET VS_VCVARS="%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat"
@CALL SET PATH=%CUDA_HOME%\bin;%PROJECT_DIR%\condabin;%PATH%

@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python=3.9 -c pytorch -c nvidia -c conda-forge -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL python -m pip install pip==23.3.1
@CALL python -m pip install gdown==5.2.0
@CALL python -m pip install -r requirements.txt

@CALL cd %PROJECT_DIR%\ext && git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1
@CALL cd %PROJECT_DIR%\ext\openpose && git submodule update --init --recursive --remote
@CALL cd %PROJECT_DIR%\ext && git clone https://github.com/hustvl/Matte-Anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything && git clone https://github.com/IDEA-Research/GroundingDINO.git
@CALL cd %PROJECT_DIR%\ext && git clone git@github.com:egorzakharov/NeuralHaircut.git --recursive
@CALL cd %PROJECT_DIR%\ext && git clone https://github.com/facebookresearch/pytorch3d
@CALL cd %PROJECT_DIR%\ext\pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL cd %PROJECT_DIR%\ext && git clone https://github.com/camenduru/simple-knn
@CALL cd %PROJECT_DIR%\ext && git clone https://github.com/g-truc/glm
@CALL cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL cd %PROJECT_DIR%\ext && git clone --recursive https://github.com/NVIDIAGameWorks/kaolin
@CALL cd %PROJECT_DIR%\ext\kaolin && git checkout v0.15.0
@CALL cd %PROJECT_DIR%\ext && git clone https://github.com/SSL92/hyperIQA
@CALL cd %PROJECT_DIR%\ext && git clone https://github.com/yfeng95/PIXIE

@CALL copy %PROJECT_DIR%\resource\NeuralHaircut\* %PROJECT_DIR%\ext\NeuralHaircut\
@CALL copy %PROJECT_DIR%\resource\hyperIQA\* %PROJECT_DIR%\ext\hyperIQA\
@CALL copy %PROJECT_DIR%\resource\openpose\* %PROJECT_DIR%\ext\openpose\
@CALL copy %PROJECT_DIR%\resource\PIXIE\data\* %PROJECT_DIR%\ext\PIXIE\data\
@CALL copy %PROJECT_DIR%\resource\NeuralHaircut\PIXIE\data\* %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\data\
@CALL copy %PROJECT_DIR%\resource\Matte-Anything\pretrained\* %PROJECT_DIR%\ext\Matte-Anything\pretrained\
@CALL %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\data\
@CALL tar -xvzf pixie_data.tar.gz
@CALL cd %PROJECT_DIR%

@CALL "%~dp0condabin\micromamba.bat" deactivate gaussian_splatting_hair

@CALL "%~dp0micromamba.exe" create -n matte_anything ^
    python=3.9 pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 opencv=4.5.3 ^
    mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale ^
    -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate matte_anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything
@CALL pip install git+https://github.com/facebookresearch/segment-anything.git
@CALL git clone https://github.com/conansherry/detectron2 %PROJECT_DIR%\ext\Matte-Anything\detectron2
@CALL cd detectron2
@CALL %VS_VCVARS% && python setup.py build develop
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO && pip install -e .
@CALL pip install supervision==0.22.0
@CALL cd %PROJECT_DIR%\ext\Matte-Anything && mkdir pretrained
@CALL cd %PROJECT_DIR%

@CALL "%~dp0condabin\micromamba.bat" deactivate
@CALL git submodule update --init --recursive --remote
@CALL "%~dp0micromamba.exe" create -n openpose cmake=3.20 -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate openpose
@CALL cd %PROJECT_DIR%\ext\openpose
@CALL mkdir build
@CALL cd build
@CALL %VS_VCVARS%
@CALL cmake .. -G "Visual Studio 17 2022" -A x64 -T host=x64 -DBUILD_PYTHON=true -DUSE_CUDNN=off
@CALL cmake --build . --config Release
@CALL cd %PROJECT_DIR%
@CALL "%~dp0condabin\micromamba.bat" deactivate

@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.8 pytorch==2.0.0 torchvision torchaudio ^
    pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib ^
    -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate pixie-env
@CALL cd %PROJECT_DIR%\ext\PIXIE
@CALL pip install pyyaml==5.4.1
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL mkdir data
@CALL 7z x utilities.zip
@CALL tar -xf pixie_data.tar
@CALL "%~dp0condabin\micromamba.bat" deactivate





























