@echo off

@CALL SET PROJECT_DIR=%~dp0

@CALL python -m pip install --upgrade pip
@CALL python -m pip install gdown

@CALL mkdir %PROJECT_DIR%\resource\NeuralHaircut\PIXIE
@CALL mkdir %PROJECT_DIR%\resource\hyperIQA\pretrained
@CALL mkdir %PROJECT_DIR%\resource\Matte-Anything\pretrained
@CALL mkdir %PROJECT_DIR%\resource\openpose

@CALL cd %PROJECT_DIR%\resource\NeuralHaircut
@CALL python -m gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
@CALL cd %PROJECT_DIR%\resource\NeuralHaircut\pretrained_models\diffusion_prior
@CALL python -m gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
@CALL cd %PROJECT_DIR%\resource\NeuralHaircut\PIXIE
@CALL python -m gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
@CALL tar -xvzf pixie_data.tar.gz ./ 
@CALL rm pixie_data.tar.gz
@CALL cd %PROJECT_DIR%\resource\hyperIQA\pretrained
@CALL python -m gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
@CALL cd %PROJECT_DIR%

@CALL cd %PROJECT_DIR%\resource\Matte-Anything\pretrained
@CALL curl -L -o sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL curl -L -o groundingdino_swint_ogc.pth https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL python -m gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

@CALL cd %PROJECT_DIR%\resource\openpose
@CALL python -m gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
@CALL tar -xvzf models.tar.gz
@CALL rm models.tar.gz













