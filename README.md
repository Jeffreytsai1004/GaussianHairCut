# GaussianHaircut

[English](README_EN.md) | [中文](README.md)

## 项目简介

GaussianHaircut 是一个用于高质量头发建模和渲染的项目，基于 3D 高斯点云技术。该项目由 ETH Zurich 的 AIT 实验室开发。

项目官方网站:[GaussianHaircut](https://eth-ait.github.io/GaussianHaircut/)
GitHub 仓库:[GaussianHaircut](https://github.com/eth-ait/GaussianHaircut)
白皮书:[GaussianHaircut](https://arxiv.org/abs/2409.00437)
项目主页:[GaussianHaircut](https://haiminluo.github.io/gaussianhair/)

## 系统要求

- Windows 10 或 Windows 11
- NVIDIA GPU (支持 CUDA 11.8)
- 至少 16GB RAM
- 至少 10GB 磁盘空间

## 必要软件

在运行 GaussianHaircut 之前，请确保安装以下软件:

1. **Python**
   - 下载链接:[https://www.python.org/ftp/python/3.8.0/python-3.8.0-amd64-webinstall.exe](https://www.python.org/ftp/python/3.8.0/python-3.8.0-amd64-webinstall.exe)
   - 将下面两个路径添加到环境变量，可根据具体情况修改：
      `C:\Program Files\Python38\`
      `C:\Program Files\Python38\Scripts\`
      `C:\Program Files\Python38\Lib\site-packages`

2. **Micromamba** (可选)
   - 下载链接:[https://micro.mamba.pm/api/micromamba/win-64/latest](https://micro.mamba.pm/api/micromamba/win-64/latest)
   - 解压至路径:`C:\Program Files\Micromamba`, 将`C:\Program Files\Micromamba\Library\bin`添加到系统 PATH 环境变量中
   - 验证安装：打开命令提示符，输入`micromamba --version`，确保显示版本信息

3. **CUDA 11.8**
   - 下载链接:[https://developer.nvidia.com/cuda-11-8-0-download-archive](https://developer.nvidia.com/cuda-11-8-0-download-archive)
   - 默认安装路径:`C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8`, 确保将`C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\bin`添加到系统 PATH 环境变量中
   - 验证安装：打开命令提示符，输入`nvcc -V`，确保显示版本信息

4. **Blender 3.6**
   - 下载链接:[https://www.blender.org/download/](https://www.blender.org/download/)
   - 默认安装路径:`C:\Program Files\Blender Foundation\Blender 3.6`, 确保将`C:\Program Files\Blender Foundation\Blender 3.6\bin`添加到系统 PATH 环境变量中
   - 安装时确保勾选“Add to PATH”选项

5. **COLMAP**
   - 下载链接:[https://github.com/colmap/colmap/releases](https://github.com/colmap/colmap/releases)
   - 建议安装路径:`C:\Program Files\Colmap`，将`C:\Program Files\Colmap\bin`目录添加到系统 PATH 环境变量中
   - 验证安装：打开命令提示符，输入`colmap help`，确保显示版本信息

6. **CMake**
   - 下载链接:[https://cmake.org/download/](https://cmake.org/download/)
   - 默认安装路径:`C:\Program Files\CMake`，将`C:\Program Files\CMake\bin`目录添加到系统 PATH 环境变量中
   - 验证安装：打开命令提示符，输入`cmake --version`，确保显示版本信息

7. **Git**
   - Git下载链接:[https://git-scm.com/download/win](https://git-scm.com/download/win)
   - Git LFS 下载链接:[https://git-lfs.com/](https://git-lfs.com/)
   - 默认安装路径:`C:\Program Files\Git`，将`C:\Program Files\Git\cmd\`, `C:\Program Files\Git\bin\`和`C:\Program Files\Git LFS\`目录添加到系统 PATH 环境变量中
   - 验证安装：打开命令提示符，输入`git --version`，确保显示版本信息

8. **Visual Studio 2022**
   - 下载链接:[https://visualstudio.microsoft.com/downloads/](https://visualstudio.microsoft.com/downloads/)
   - 确保安装 "使用 C++ 的桌面开发" 工作负载
   - 将下面两个路径添加到环境变量，可根据具体情况修改：
     - `C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\`
     - `C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build`
     - `C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64`

9. **VS Build Tool**(可选)
   - 下载链接:[https://visualstudio.microsoft.com/zh-hans/visual-cpp-build-tools/](https://visualstudio.microsoft.com/zh-hans/visual-cpp-build-tools/)

10.  **FFmpeg**
   - 下载链接:[https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip](ffmpeg-master-latest-win64-gpl.zip)
   - 默认安装路径:`C:\Program Files\FFmpeg`, 将解压后的文件复制到此路径，并将`C:\Program Files\FFmpeg\bin`目录添加到系统 PATH 环境变量中
   - 验证安装：打开命令提示符，输入`ffmpeg -version`，确保显示版本信息

11.   **gcc**
   - 下载链接:[https://github.com/jmeubank/tdm-gcc/releases/download/v10.3.0-tdm64-2/tdm64-gcc-10.3.0-2.exe](https://github.com/jmeubank/tdm-gcc/releases/download/v10.3.0-tdm64-2/tdm64-gcc-10.3.0-2.exe)
   - 点击`create`安装,选择`MinGW-w64/TDM64(32-bit and 64-bit)`,推荐安装路径`C:\Program Files\TDM-GCC-64`,并将`C:\Program Files\TDM-GCC-64\bin`目录添加到系统 PATH 环境变量中
   - 验证安装：打开命令提示符，输入`gcc --version`，确保显示版本信息

12. **wget** (可选)
   - 下载链接:[https://eternallybored.org/misc/wget/](https://eternallybored.org/misc/wget/)
   - 下载系统对应版本的exe，并拷贝到`C:\Windows\System32`即可

13. **CUB**
   - 下载链接:[https://github.com/NVlabs/cub.git](https://github.com/NVlabs/cub.git)
   - 设置环境变量`CUB_HOM`为Cub安装路径, 或直接设置变量`set CUB_HOME=C:\path\to\cub`

14. **openpose**
   - 下载链接:[https://github.com/Jeffreytsai1004/Openpose](https://github.com/Jeffreytsai1004/Openpose)
   - 默认安装路径:`C:\Program Files\OpenPose`, 将解压后的文件复制到此路径，并将`C:\Program Files\OpenPose`目录添加到系统 PATH 环境变量中

## 安装步骤

1. 克隆仓库:
   ```
   git clone https://github.com/eth-ait/GaussianHaircut.git
   cd GaussianHaircut
   ```

2. 运行安装脚本:
   ```
   install.bat
   ```
   
   此脚本将:
   - 检查必要软件是否已安装
   - 下载 micromamba 用于环境管理
   - 创建 Python 虚拟环境
   - 安装所有依赖项
   - 编译 CUDA 扩展

## 使用方法

1. 准备数据:
   - 将您的数据放在 `data` 目录下的子文件夹中

2. 运行程序:
   ```
   run.bat
   ```
   
   此脚本将显示一个菜单，您可以选择:
   - 数据处理
   - 模型训练
   - 模型导出

## 环境变量

默认环境变量设置如下,可以根据需要修改,请确保您的系统 PATH 环境变量包含这些路径:
COLMAP_PATH=C:\Program Files\Colmap\bin
CMAKE_PATH=C:\Program Files\CMake\bin
FFMPEG_PATH=C:\Program Files\FFmpeg\bin
BLENDER_PATH=C:\Program Files\Blender Foundation\Blender 3.6
CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
VCVARS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build

如果您的软件安装在不同的位置，请在 `install.bat` 和 `run.bat` 文件中修改相应的路径。

## install.bat 安装主要步骤:

#### 1 环境检查与设置环境变量
#### 2 用micromamba设置虚拟环境,并测试
#### 3 拉取代码与依赖
#### 4 构建必要模块(如pytorch,openpose,pixie,detectron2 等等)
#### 5 下载大模型
#### 6 测试

## run.bat 运行主要步骤:
#### 1 预处理:
#####     将原始图像排列成 3D 高斯 Splatting 格式
#####     运行 COLMAP 重建并对图像和相机进行去畸变
#####     运行 Matte-Anything
#####     调整图像大小
#####     使用图像的 IQA 分数进行过滤
#####     计算方向图
#####     运行 OpenPose
#####     运行 Face-Alignment
#####     运行 PIXIE
#####     将所有 PIXIE 预测合并到一个文件中
#####     将 COLMAP 相机转换为 txt 格式
#####     将 COLMAP 相机转换为 H3DS 格式
#####     删除原始文件以节省磁盘空间
#### 2 重建:
#####     运行 3D 高斯 Splatting 重建
#####     运行 FLAME 网格拟合
#####     裁剪重建场景
#####     移除与 FLAME 头部网格相交的头发高斯分布
#####     运行训练视图渲染
#####     获取 FLAME 网格头皮图
#####     运行潜在发束重建
#####     运行发束重建
#### 3 可视化:
#####     将生成的发束导出为 pkl 和 ply 文件
#####     渲染可视化效果
#####     渲染线条
#####     制作视频

## 故障排除

如果遇到问题:

1. 确保所有必要软件都已正确安装
2. 检查环境变量是否正确设置
3. 查看控制台输出的错误信息
4. 如果 CUDA 扩展编译失败，确保 Visual Studio 和 CUDA 版本兼容

#### 1 环境检查与设置环境变量
这部分看起来已经很完善，但有几点需要注意：
确保所有路径中没有空格或特殊字符，如果有，请使用引号包围
确保 PATH 环境变量设置正确，特别是 CUDA 路径
#### 2 虚拟环境设置
这部分可能会遇到的问题：
micromamba 下载失败：可以手动下载并放置在项目目录
环境创建失败：可能是网络问题或依赖冲突，可以尝试分步创建
#### 3 拉取代码与依赖
这部分需要注意：
确保 Git 能够正常访问外部仓库
如果某些仓库克隆失败，可以手动下载并解压
#### 4 构建必要模块
这是最容易出问题的部分：
OpenPose 编译可能会失败，需要确保 Visual Studio 和 CUDA 版本兼容
CUDA 扩展编译可能会失败，需要检查 CUDA 路径和编译器设置
#### 5 下载大模型
这部分可能会遇到的问题：
下载失败：可能是网络问题，可以尝试使用代理或手动下载
解压失败：确保有足够的磁盘空间和权限
#### CUDA 相关问题：
错误：找不到 CUDA 或 CUDA 版本不兼容
解决方案：确保安装了 CUDA 11.8，并且 PATH 环境变量正确设置
#### Visual Studio 相关问题：
错误：找不到 Visual Studio 或版本不兼容
解决方案：确保安装了 Visual Studio 2022，并且包含 C++ 开发组件
#### 依赖安装问题：
错误：pip 安装依赖失败
解决方案：检查网络连接，尝试使用国内镜像源
#### OpenPose 编译问题：
错误：OpenPose 编译失败
解决方案：检查 CMake 和 Visual Studio 设置，或尝试使用预编译版本
#### 模型下载问题：
错误：模型下载失败
解决方案：检查网络连接，尝试使用代理或手动下载

## 许可证

请参阅原始项目的许可证信息:[https://github.com/eth-ait/GaussianHaircut](https://github.com/eth-ait/GaussianHaircut)
