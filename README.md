# Gaussian Haircut: Human Hair Reconstruction with Strand-Aligned 3D Gaussians

[**中文**](README_CN.md) | [**English**](README.md)

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

Required resource structure:
```
resource/
├── NeuralHaircut/
│   ├── pretrained_models/
│   │   ├── diffusion_prior/
│   │   │   └── dif_ckpt.pt          ## Diffusion prior model
│   │   └── strand_prior/
│   │       └── strand_ckpt.pt       ## Strand prior model
│   └── PIXIE/
│       └── pixie_data/
├── Matte-Anything/
├── openpose/
└── hyperIQA/
```

## Getting Started

### Linux Platform

1. **Install CUDA 11.8**

   按照 https://developer.nvidia.com/cuda-11-8-0-download-archive 上的说明进行操作。

   确保：
   - PATH 包含 <CUDA_DIR>/bin
   - LD_LIBRARY_PATH 包含 <CUDA_DIR>/lib64

   该环境仅在此 CUDA 版本下进行了测试。

2. **Install Blender 3.6** 以创建股线可视化

   按照 https://www.blender.org/download/lts/3-6 上的说明进行操作。

3. **Clone repository and run installation script**

   ```bash
   git clone git@github.com:eth-ait/GaussianHaircut.git
   cd GaussianHaircut
   chmod +x ./install.sh
   ./install.sh
   ```

### Windows Platform

1. **Install CUDA 11.8**
    - 从 https://developer.nvidia.com/cuda-11-8-0-download-archive 下载并安装
    - 默认安装路径：C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
    - 确保CUDA版本与系统兼容

2. **Install Blender 3.6**
    - 从 https://www.blender.org/download/lts/3-6 下载并安装
    - 默认安装路径：C:\Program Files\Blender Foundation\Blender 3.6

3. **Install Visual Studio 2019 Build Tools**
    - 从 https://visualstudio.microsoft.com/vs/older-downloads/ 下载并安装
    - 选择"C++构建工具"工作负载
    - 默认安装路径：C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools

4. **Install COLMAP**
    - 从 https://github.com/colmap/colmap/releases 下载并安装
    - 下载CUDA版本的COLMAP (例如：COLMAP-3.8-windows-cuda.zip)
    - 解压到不含空格的路径 (例如：C:\COLMAP)
    - 将COLMAP目录添加到系统PATH:
      1. 打开"系统属性" > "环境变量"
      2. 在"系统变量"中找到"Path"
      3. 点击"编辑" > "新建"
      4. 添加COLMAP目录路径
      5. 点击"确定"保存
    - 重启终端使PATH生效

5. **Install 7-Zip**
    - 从 https://7-zip.org/ 下载并安装
    - 将7-Zip安装目录添加到系统PATH:
      1. 打开"系统属性" > "环境变量"
      2. 在"系统变量"中找到"Path"
      3. 点击"编辑" > "新建"
      4. 添加7-Zip安装目录(默认为C:\Program Files\7-Zip)
      5. 点击"确定"保存
    - 重启终端使PATH生效

6. **Download pre-trained models and resources**
    ```cmd
    git clone https://github.com/Jeffreytsai1004/GaussianHairCut
    cd GaussianHairCut
    # 在PowerShell中运行:
    # 脚本会自动安装gdown并下载所需资源
    .\download_resource.bat
    ```
    注意：
    - 下载过程可能需要几分钟到几十分钟，取决于网络速度
    - 如果下载失败，可以重新运行脚本
    - 确保有稳定的网络连接

6. **Clone repository and run installation script**
    ```cmd
    git clone https://github.com/Jeffreytsai1004/GaussianHairCut
    cd GaussianHairCut
    # 先下载所需要的资源
    .\download_resource.bat
    # 运行安装脚本
    .\install.bat
    # 运行重建脚本
    .\run.bat
    ```

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

2. **Setup Scene Directory**

   ```cmd
   # In CMD:
   set PROJECT_DIR=[path\to\]GaussianHaircut
   set DATA_PATH=[path\to\scene\folder]
   run.bat
   
   # Or in PowerShell:
   $env:PROJECT_DIR="[path\to\]GaussianHaircut"
   $env:DATA_PATH="[path\to\scene\folder]"
   .\run.bat
   ```
   
   Note:
   - DATA_PATH should point to directory containing raw.mp4
   - Directory paths should not contain spaces or special characters
   - Ensure sufficient disk space (at least 20GB recommended)

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
