@echo off

@CALL SET PROJECT_DIR=%~dp0

@CALL python -m pip install --upgrade pip
@CALL python -m pip install gdown
@CALL python -m pip install wget
@CALL python -m pip install tar

@CALL mkdir %PROJECT_DIR%\resource\NeuralHaircut\PIXIE
@CALL mkdir %PROJECT_DIR%\resource\hyperIQA\pretrained
@CALL mkdir %PROJECT_DIR%\resource\Matte-Anything\pretrained
@CALL mkdir %PROJECT_DIR%\resource\openpose
@CALL mkdir %PROJECT_DIR%\resource\PIXIE\data

echo "Downloading NeuralHaircut..."
@CALL cd %PROJECT_DIR%\resource\NeuralHaircut
@CALL python -m gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
@CALL cd %PROJECT_DIR%
@CALL cd %PROJECT_DIR%\resource\NeuralHaircut\pretrained_models\diffusion_prior
@CALL python -m gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
@CALL cd %PROJECT_DIR%
echo "Downloading PIXIE..."
@CALL cd %PROJECT_DIR%\resource\NeuralHaircut\PIXIE
@CALL python -m gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
@CALL tar -xvzf pixie_data.tar.gz
@CALL cd %PROJECT_DIR%
echo "Downloading hyperIQA..."
@CALL cd %PROJECT_DIR%\resource\hyperIQA\pretrained
@CALL python -m gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
@CALL cd %PROJECT_DIR%

echo "Downloading Matte-Anything..."
@CALL cd %PROJECT_DIR%\resource\Matte-Anything\pretrained
@CALL python -m wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL python -m wget https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL python -m gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW
@CALL cd %PROJECT_DIR%

echo "Downloading openpose..."
@CALL cd %PROJECT_DIR%\resource\openpose
@CALL python -m gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
@CALL tar -xvzf models.tar.gz
@CALL cd %PROJECT_DIR%

echo "Downloading PIXIE..."
@CALL cd %PROJECT_DIR%\resource\PIXIE\
@CALL mkdir data
@CALL curl -u "jeffreytsai1004@gmail.com:Caijianbo6637@" -i "https://download.is.tue.mpg.de/download.php?domain=smplx&sfile=SMPLX_NEUTRAL_2020.npz&resume=1" -o "./data/SMPLX_NEUTRAL_2020.npz"
@CALL curl -u "jeffreytsai1004@gmail.com:Caijianbo6637@" -i "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=pixie_model.tar&resume=1" -o "./data/pixie_model.tar"
@CALL curl -u "jeffreytsai1004@gmail.com:Caijianbo6637@" -i "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=utilities.zip&resume=1" -o "./data/utilities.zip"
echo "PIXIE model download complete"
@CALL cd data
@CALL tar -xf utilities.zip
@CALL tar -xvzf pixie_model.tar
@CALL cd %PROJECT_DIR%
echo "Download complete"

echo pause













