# Gaussian Haircut：使用股线对齐 3D 高斯模型进行人体头发重建

[**论文**](https://arxiv.org/abs/2409.14778) | [**项目页面**](https://eth-ait.github.io/GaussianHaircut/)

本仓库包含了 Gaussian Haircut 的官方实现，这是一种基于股线的人体头发重建方法，用于单目视频。

## 预览

重建过程包括以下主要阶段：

1. **预处理阶段**
   - 视频帧提取和整理
   - COLMAP相机重建
   - 头发和身体分割
   - 图像质量评估和筛选
   - 方向图计算
   - 人脸关键点检测
   - FLAME头部模型拟合

2. **重建阶段**
   - 3D高斯体重建
   - FLAME网格拟合
   - 场景裁剪和优化
   - 头发股线重建

3. **可视化阶段**
   - 导出重建的股线
   - Blender渲染可视化
   - 生成结果视频

预期输出：
```
[your_scene_folder]/
├── raw.mp4                    # 输入视频
├── 3d_gaussian_splatting/     # 3D高斯体重建结果
├── flame_fitting/             # FLAME头部模型拟合结果
├── strands_reconstruction/    # 头发股线重建中间结果
├── curves_reconstruction/     # 最终头发股线结果
└── visualization/            # 渲染结果和视频
```

## 入门指南

### Linux 平台

1. **安装 CUDA 11.8**

   按照 https://developer.nvidia.com/cuda-11-8-0-download-archive 上的说明进行操作。

   确保：
   - PATH 包含 <CUDA_DIR>/bin
   - LD_LIBRARY_PATH 包含 <CUDA_DIR>/lib64

   该环境仅在此 CUDA 版本下进行了测试。

2. **安装 Blender 3.6** 以创建股线可视化

   按照 https://www.blender.org/download/lts/3-6 上的说明进行操作。

3. **克隆仓库并运行安装脚本**

   ```bash
   git clone git@github.com:eth-ait/GaussianHaircut.git
   cd GaussianHaircut
   chmod +x ./install.sh
   ./install.sh
   ```

### Windows 平台

1. **安装 CUDA 11.8**
    - 从 https://developer.nvidia.com/cuda-11-8-0-download-archive 下载并安装
    - 默认安装路径：C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8

2. **安装 Blender 3.6**
    - 从 https://www.blender.org/download/lts/3-6 下载并安装
    - 默认安装路径：C:\Program Files\Blender Foundation\Blender 3.6

3. **安装 Visual Studio 2019 Build Tools**
    - 从 https://visualstudio.microsoft.com/vs/older-downloads/ 下载并安装
    - 选择"C++构建工具"工作负载
    - 默认安装路径：C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools

4. **安装 COLMAP**
    - 从 https://github.com/colmap/colmap/releases 下载并安装
    - 下载最新的Windows安装包(例如：COLMAP-3.8-windows-cuda.zip)
    - 解压到一个不含空格的路径(例如：C:\COLMAP)
    - 确保CUDA版本与系统安装的CUDA 11.8匹配
    - 将解压目录(C:\COLMAP)添加到系统环境变量PATH中:
      1. 打开"系统属性" > "环境变量"
      2. 在"系统变量"中找到"Path"
      3. 点击"编辑" > "新建"
      4. 添加COLMAP目录路径(C:\COLMAP)
      5. 点击"确定"保存更改
    - 重启PowerShell或CMD以使PATH更改生效
    - 验证安装：
      ```cmd
      colmap -h
      ```
      如果显示帮助信息，则安装成功

5. **安装 micromamba**
    - 从 [https://mamba.readthedocs.io/en/latest/installation.html](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) 下载并安装

6. **克隆仓库并运行安装脚本**

    ```cmd
    git clone https://github.com/Jeffreytsai1004/GaussianHairCut
    cd GaussianHaircut
    # 在CMD中运行:
    install.bat
    # 或在PowerShell中运行:
    .\install.bat
    ```

## 重建

1. **录制单目视频**

   - 参考项目页面上的示例视频
   - 录制要求：
     * 拍摄对象应缓慢转动头部，确保捕捉到所有角度
     * 保持头发和面部清晰可见
     * 避免快速移动导致的运动模糊
     * 保持光照条件稳定
     * 建议视频长度：10-20秒
     * 建议分辨率：1920x1080或更高

2. **设置重建场景的目录**

   创建场景目录结构：
   ```
   [your_scene_folder]/
   └── raw.mp4  # 您录制的视频文件
   ```
   
   注意：
   - DATA_PATH 应指向包含 raw.mp4 的目录
   - 目录路径不应包含空格或特殊字符
   - 脚本会在此目录下自动创建所需的子目录
   - 确保有足够的磁盘空间(建议至少20GB)

3. **运行脚本**

Linux:
   ```bash
   export PROJECT_DIR="[/path/to/]GaussianHaircut"
   export BLENDER_DIR="[/path/to/blender/folder/]blender"
   DATA_PATH="[path/to/scene/folder]" ./run.sh
   ```

Windows:
   ```cmd
   # 在CMD中运行:
   set PROJECT_DIR=[path\to\]GaussianHaircut
   set DATA_PATH=[path\to\scene\folder]
   run.bat
   
   # 或在PowerShell中运行:
   set PROJECT_DIR=[path\to\]GaussianHaircut
   set DATA_PATH=[path\to\scene\folder]
   .\run.bat
   ```

   该脚本执行数据预处理、重建以及使用 Blender 进行最终可视化。使用 Tensorboard 查看中间可视化结果。

## 许可证

此代码基于 3D Gaussian Splatting 项目。有关条款和条件，请参阅 LICENSE_3DGS。其余代码根据 CC BY-NC-SA 4.0 分发。

如果此代码对您的项目有帮助，请引用以下论文。

## 引用

```
@inproceedings{zakharov2024gh,
   title = {Human Hair Reconstruction with Strand-Aligned 3D Gaussians},
   author = {Zakharov, Egor and Sklyarova, Vanessa and Black, Michael J and Nam, Giljoo and Thies, Justus and Hilliges, Otmar},
   booktitle = {European Conference of Computer Vision (ECCV)},
   year = {2024}
} 
```

## 链接

- [3D Gaussian Splatting](https://github.com/graphdeco-inria/gaussian-splatting)
- [Neural Haircut](https://github.com/SamsungLabs/NeuralHaircut): FLAME 拟合管线、股线先验和发型扩散先验
- [HAAR](https://github.com/Vanessik/HAAR): 头发上采样
- [Matte-Anything](https://github.com/hustvl/Matte-Anything): 头发和身体分割
- [PIXIE](https://github.com/yfeng95/PIXIE): FLAME 拟合的初始化
- [Face-Alignment](https://github.com/1adrianb/face-alignment), [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose): 用于 FLAME 拟合的关键点检测
