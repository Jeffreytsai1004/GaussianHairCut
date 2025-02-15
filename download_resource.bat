@echo off
setlocal enabledelayedexpansion

REM 创建resource目录结构
mkdir resource 2>nul
mkdir resource\NeuralHaircut\diffusion_prior 2>nul
mkdir resource\NeuralHaircut\PIXIE 2>nul
mkdir resource\Matte-Anything 2>nul
mkdir resource\openpose\models 2>nul
mkdir resource\hyperIQA\pretrained 2>nul

REM 下载 Neural Haircut 文件
cd resource\NeuralHaircut
gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
cd diffusion_prior
gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
cd ..\PIXIE
gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
tar -xf pixie_data.tar.gz
del pixie_data.tar.gz

REM 下载 Matte-Anything 文件
cd ..\..\Matte-Anything
curl -LO https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
curl -LO https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW -O model.pth

REM 下载 OpenPose 模型
cd ..\openpose
gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV -O models.tar.gz
tar -xf models.tar.gz -C models
del models.tar.gz

REM 下载 hyperIQA 模型
cd ..\hyperIQA\pretrained
gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE

cd ..\..
echo Download completed!
