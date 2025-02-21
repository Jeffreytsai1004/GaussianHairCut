# Gaussian Haircut: Human Hair Reconstruction with Strand-Aligned 3D Gaussians

[**中文**](README.md) | [**English**](README_EN.md)

This repository contains the official implementation of Gaussian Haircut, a strand-based human hair reconstruction method from monocular video.

[**Paper**](https://arxiv.org/abs/2409.14778) | [**Project Page**](https://eth-ait.github.io/GaussianHaircut/)

## Overview

The reconstruction process includes the following main stages:

1. **Preprocessing Stage**
   - Video frame extraction and organization
   - COLMAP camera reconstruction
   - Hair and body segmentation
   - Image quality assessment and filtering
   - Orientation map calculation
   - Facial keypoint detection
   - FLAME head model fitting

2. **Reconstruction Stage**
   - 3D Gaussian reconstruction
   - FLAME mesh fitting
   - Scene cropping and optimization
   - Hair strand reconstruction

3. **Visualization Stage**
   - Export reconstructed strands
   - Blender rendering visualization
   - Generate result video

Expected output:
```
[your_scene_folder]/
├── raw.mp4                    # Input video
├── 3d_gaussian_splatting/     # 3D Gaussian reconstruction results
├── flame_fitting/             # FLAME head model fitting results
├── strands_reconstruction/    # Hair strand reconstruction intermediate results
├── curves_reconstruction/     # Final hair strand results
└── visualization/            # Rendering results and video
```

Resource directory:
```
resource/
├── hyperIQA/                                # HyperIQA model
│   └── pretrained/
│       └── koniq_pretrained.pkl
├── Matte-Anything/                          # Matte-Anything models
│   └── pretrained/
│       ├── groundingdino_swint_ogc.pth
│       ├── sam_vit_h_4b8939.pth
│       └── ViTMatte_B_DIS.pth
├── NeuralHaircut/                          # NeuralHaircut models
│   ├── PIXIE/
│   │   └── pixie_data.tar.gz
│   └── pretrained_models/
│       ├── diffusion_prior/
│       │   ├── dif_ckpt.pth
│       │   └── wo_bug_blender_uv_00130000.pth
│       └── strand_prior/
│           └── strand_ckpt.pth
├── openpose/                               # OpenPose models
│   ├── models/
│   │   ├── cameraParameters/
│   │   ├── face/
│   │   ├── hand/
│   │   ├── pose/
│   │   ├── getModels.bat
│   │   ├── getModels.sh
│   │   └── wget-log
│   └── models.tar.gz
├── PIXIE/                                  # PIXIE utilities and models
│   └── data/
│       ├── pixie_model.tar
│       ├── SMPLX_NEUTRAL_2020.npz
│       └── utilities.zip
```

## Environment Variables

Required environment variables:

```batch
@CALL SET PROJECT_DIR=%~dp0
@CALL SET MICROMAMBA_EXE=%PROJECT_DIR%\micromamba.exe
@CALL SET CUDA_HOME="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\"
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET VS_DIR="C:\Program Files\Microsoft Visual Studio\2022\Professional\"
@CALL SET VS_VCVARS="%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat"
```

## Getting Started

### Linux Platform

1. **Install CUDA 11.8**

   Follow instructions at https://developer.nvidia.com/cuda-11-8-0-download-archive

   Make sure:
   - PATH includes <CUDA_DIR>/bin
   - LD_LIBRARY_PATH includes <CUDA_DIR>/lib64

   The environment was tested only with this CUDA version.

2. **Install Blender 3.6** for strand visualization

   Follow instructions at https://www.blender.org/download/lts/3-6

3. **Clone repository and run installation script**

   ```bash
   git clone git@github.com:eth-ait/GaussianHaircut.git
   cd GaussianHaircut
   chmod +x ./install.sh
   ./install.sh
   ```

### Windows Platform

1. **Install CUDA 11.8**
    - Download and install from https://developer.nvidia.com/cuda-11-8-0-download-archive
    - Default installation path: C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
    - Ensure CUDA version is compatible with your system

2. **Install Blender 3.6**
    - Download and install from https://www.blender.org/download/lts/3-6
    - Default installation path: C:\Program Files\Blender Foundation\Blender 3.6

3. **Install Visual Studio 2019 Build Tools**
    - Download and install from https://visualstudio.microsoft.com/vs/older-downloads/
    - Select "C++ Build Tools" workload
    - Default installation path: C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools

4. **Install COLMAP**
    - Download from https://github.com/colmap/colmap/releases
    - Download CUDA version of COLMAP (e.g., COLMAP-3.8-windows-cuda.zip)
    - Extract to a path without spaces (e.g., C:\COLMAP)
    - Add COLMAP directory to system PATH:
      1. Open "System Properties" > "Environment Variables"
      2. Under "System Variables", find "Path"
      3. Click "Edit" > "New"
      4. Add COLMAP directory path
      5. Click "OK" to save
    - Restart terminal for PATH changes to take effect

5. **Install 7-Zip**
    - Download and install from https://7-zip.org/
    - Add 7-Zip installation directory to system PATH:
      1. Open "System Properties" > "Environment Variables"
      2. Under "System Variables", find "Path"
      3. Click "Edit" > "New"
      4. Add 7-Zip installation directory (default: C:\Program Files\7-Zip)
      5. Click "OK" to save
    - Restart terminal for PATH changes to take effect

6. **Download pre-trained models and resources**
    ```cmd
    git clone https://gitea.cgnico.com/CGNICO/GaussianHaircut
    cd GaussianHairCut
    # Run in PowerShell:
    # The script will automatically install gdown and download required resources
    .\download_resource.bat
    ```
    Note:
    - Download time varies from minutes to tens of minutes depending on network speed
    - If download fails, you can rerun the script
    - Ensure stable network connection

## Usage

1. **Record Monocular Video**
   - Reference example videos on the project page
   - Recording requirements:
     * Subject should rotate head slowly to capture all angles
     * Keep hair and face clearly visible
     * Avoid motion blur from fast movements
     * Maintain stable lighting conditions
     * Recommended length: 10-20 seconds
     * Recommended resolution: 1920x1080 or higher
   Note:
   - DATA_PATH should point to directory containing raw.mp4
   - Directory paths should not contain spaces or special characters
   - Ensure sufficient disk space (at least 20GB recommended)

2. **Setup Scene Directory**
   - Create a new folder, e.g., C:\path\to\scene\folder
   - Place raw.mp4 in this folder

3. **Run Installation and Reconstruction Scripts**
   - Set environment variables PROJECT_DIR and DATA_PATH in install.bat and run.bat
   - For example:
   ```cmd
   set "PROJECT_DIR=C:\path\to\project"
   set "DATA_PATH=C:\path\to\scene\folder"
   ```
   - Modify environment variables CUDA_HOME, BLENDER_DIR, VS_DIR in install.bat and run.bat
   ```cmd
   set "CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
   set "BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6"
   set "VS_DIR=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools"
   ```
   - Run installation script
   ```cmd
   .\install.bat
   ```
   - Run reconstruction script
   ```cmd
   .\run.bat
   ```

## License

This code is based on the 3D Gaussian Splatting project. See LICENSE_3DGS for terms and conditions. The rest of the code is distributed under CC BY-NC-SA 4.0.

## Citation

If you find this code helpful for your research, please cite our paper:

```bibtex
@inproceedings{zakharov2024gh,
   title = {Human Hair Reconstruction with Strand-Aligned 3D Gaussians},
   author = {Zakharov, Egor and Sklyarova, Vanessa and Black, Michael J and Nam, Giljoo and Thies, Justus and Hilliges, Otmar},
   booktitle = {European Conference of Computer Vision (ECCV)},
   year = {2024}
} 
```

## Related Projects

- [3D Gaussian Splatting](https://github.com/graphdeco-inria/gaussian-splatting)
- [Neural Haircut](https://github.com/SamsungLabs/NeuralHaircut): FLAME fitting pipeline, strand prior and hairstyle diffusion prior
- [HAAR](https://github.com/Vanessik/HAAR): Hair upsampling
- [Matte-Anything](https://github.com/hustvl/Matte-Anything): Hair and body segmentation
- [PIXIE](https://github.com/yfeng95/PIXIE): FLAME fitting initialization
- [Face-Alignment](https://github.com/1adrianb/face-alignment), [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose): Keypoint detection for FLAME fitting
