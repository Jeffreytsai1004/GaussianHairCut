# GaussianHaircut

[English](README_EN.md) | [中文](README.md)

## Project Introduction

GaussianHaircut is a project for high-quality hair modeling and rendering based on 3D Gaussian point cloud technology. The project was developed by the AIT lab at ETH Zurich.

Official project website: [GaussianHaircut](https://eth-ait.github.io/GaussianHaircut/)
GitHub repository: [GaussianHaircut](https://github.com/eth-ait/GaussianHaircut)
Whitepaper: [GaussianHaircut](https://arxiv.org/abs/2409.00437)
Project homepage: [GaussianHaircut](https://haiminluo.github.io/gaussianhair/)

## System requirements

- Windows 10 or Windows 11
- NVIDIA GPU (supports CUDA 11.8)
- At least 16GB RAM
- At least 10GB disk space

## Required software

Before running GaussianHaircut, make sure the following software is installed:

1. **Micromamba**
- Download link: [https://micro.mamba.pm/api/micromamba/win-64/latest](https://micro.mamba.pm/api/micromamba/win-64/latest)
- Unzip to path: `C:\Program Files\Micromamba`, add `C:\Program Files\Micromamba\Library\bin` to the system PATH environment variable
- Verify installation: Open the command prompt, enter `micromamba --version`, and make sure the version information is displayed

2. **CUDA 11.8**
- Download link: [https://developer.nvidia.com/cuda-11-8-0-download-archive](https://developer.nvidia.com/cuda-11-8-0-download-archive)
- Default installation path: `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8`, make sure to add `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\bin` to the system PATH environment variable
- Verify installation: Open the command prompt, enter `nvcc -V`, and make sure the version information is displayed

3. **Blender 3.6**
- Download link: [https://www.blender.org/download/](https://www.blender.org/download/)
- Default installation path: `C:\Program Files\Blender Foundation\Blender 3.6`, make sure to add `C:\Program Files\Blender Foundation\Blender 3.6\bin` to the system PATH environment variable
- Make sure to check the "Add to PATH" option when installing

4. **COLMAP**
- Download link: [https://github.com/colmap/colmap/releases](https://github.com/colmap/colmap/releases)
- Recommended installation path: `C:\Program Files\Colmap`, add the `C:\Program Files\Colmap\bin` directory to the system PATH environment variable
- Verify installation: Open the command prompt, enter `colmap help`, and make sure the version information is displayed

5. **CMake**
- Download link: [https://cmake.org/download/](https://cmake.org/download/)
- Default installation path: `C:\Program Files\CMake`, add the `C:\Program Files\CMake\bin` directory to the system PATH environment variable
- Verify installation: Open the command prompt, enter `cmake --version`, and make sure the version information is displayed

6. **Git**
- Git download link: [https://git-scm.com/download/win](https://git-scm.com/download/win)
- Git LFS download link: [https://git-lfs.com/](https://git-lfs.com/)
- Default installation path: `C:\Program Files\Git`, add `C:\Program Files\Git\cmd\`, `C:\Program Files\Git\bin\` and `C:\Program Files\Git LFS\` directories to the system PATH environment variable
- Verify installation: Open the command prompt, enter `git --version`, and make sure the version information is displayed

7. **Visual Studio 2022**
- Download link: [https://visualstudio.microsoft.com/downloads/](https://visualstudio.microsoft.com/downloads/)
- Make sure to install the "Desktop development with C++" workload

8. **FFmpeg**
- Download link: [https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip](ffmpeg-master-latest-win64-gpl.zip)
- Default installation path: `C:\Program Files\FFmpeg`, copy the unzipped files to this path, and add the `C:\Program Files\FFmpeg\bin` directory to the system PATH environment variable
- Verify installation: Open the command prompt, enter `ffmpeg -version`, and make sure the version information is displayed

12. **wget** (optional)
- Download link: [https://eternallybored.org/misc/wget/](https://eternallybored.org/misc/wget/)
- Download the exe version corresponding to the system and copy it to `C:\Windows\System32`

## Installation steps

1. Clone the repository:
```
git clone https://github.com/eth-ait/GaussianHaircut.git
cd GaussianHaircut
```

2. Run the installation script:
```
install.bat
```

This script will:
- Check if the necessary software is installed
- Download micromamba for environment management
- Create Python virtual environment
- Install all dependencies
- Compile CUDA extension

## How to use

1. Prepare data:
- Put your data in a subfolder under the `data` directory

2. Run the program:
```
run.bat
```

This script will display a menu where you can choose:
- Data processing
- Model training
- Model export

## Environment variables

The default environment variables are set as follows and can be modified as needed. Please make sure your system PATH environment variable contains these paths:
COLMAP_PATH=C:\Program Files\Colmap\bin
CMAKE_PATH=C:\Program Files\CMake\bin
FFMPEG_PATH=C:\Program Files\FFmpeg\bin
BLENDER_PATH=C:\Program Files\Blender Foundation\Blender 3.6
CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
VCVARS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build

If your software is installed in a different location, please modify the corresponding path in the `install.bat` and `run.bat` files.

## install.bat Main steps for installation:

#### 1 Check the environment and set environment variables
#### 2 Set up a virtual environment with micromamba and test
#### 3 Pull code and dependencies
#### 4 Build necessary modules (such as pytorch, openpose, pixie, detectron2, etc.)
#### 5 Download large models
#### 6 Test

## run.bat Main steps for running:
#### 1 Preprocessing:
##### Arrange the original image into 3D Gaussian Splatting format
###### Run COLMAP reconstruction and dedistort the image and camera
###### Run Matte-Anything
##### Resize the image
###### Filter using the image's IQA score
##### Calculate the direction map
###### Run OpenPose
###### Run Face-Alignment
##### Run PIXIE
##### Merge all PIXIE predictions into one file
##### Convert COLMAP camera to txt format
##### Convert COLMAP camera to H3DS format
##### Delete original files to save disk space
#### 2 Reconstruction:
##### Run 3D Gaussian Splatting reconstruction
##### Run FLAME mesh fitting
##### Crop the reconstructed scene
##### Remove the hair Gaussian distribution that intersects the FLAME head mesh
##### Run training view rendering
##### Get FLAME mesh scalp map
##### Run potential hair bundle reconstruction
##### Run hair bundle reconstruction
##### 3 Visualization:
##### Export the generated hair bundles as pkl and ply files
##### Rendering visualizations
##### Rendering lines
##### Making videos

## Troubleshooting

If you encounter problems:

1. Make sure all necessary software is installed correctly
2. Check if the environment variables are set correctly
3. Check the error message output by the console
4. If the CUDA extension compilation fails, make sure that the Visual Studio and CUDA versions are compatible

#### 1 Environment check and setting environment variables
This part looks very complete, but there are a few points to note:
Make sure there are no spaces or special characters in all paths. If there are, please surround them with quotation marks
Make sure the PATH environment variable is set correctly, especially the CUDA path
#### 2 Virtual environment settings
Problems that may be encountered in this part:
Failed to download micromamba: You can download it manually and place it in the project directory
Failed to create the environment: It may be a network problem or dependency conflict. You can try to create it step by step
#### 3 Pull code and dependencies
Note this part:
Make sure Git Able to access external repositories normally
If some repositories fail to clone, you can manually download and unzip
#### 4 Build necessary modules
This is the most problematic part:
OpenPose compilation may fail, you need to ensure that Visual Studio and CUDA versions are compatible
CUDA extension compilation may fail, you need to check CUDA path and compiler settings
#### 5 Download large models
Problems that may be encountered in this part:
Download failure: It may be a network problem, you can try to use a proxy or download manually
Unzip failure: Make sure there is enough disk space and permissions
#### CUDA related issues:
Error: Cannot find CUDA or CUDA version is incompatible
Solution: Make sure CUDA is installed 1