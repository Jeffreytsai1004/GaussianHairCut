@echo off
setlocal enabledelayedexpansion

REM 设置环境变量
SET MICROMAMBA_EXE=%~dp0micromamba.exe
SET MAMBA_ROOT_PREFIX=%~dp0micromamba
SET CUDA_VISIBLE_DEVICES=0
SET CAMERA=PINHOLE
SET EXP_NAME_1=stage1
SET EXP_NAME_2=stage2
SET EXP_NAME_3=stage3
SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6"
SET CUDA_HOME="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"

REM 确保以下环境变量可用:
REM PROJECT_DIR 和 DATA_PATH

REM 检查必要的环境变量
IF "%PROJECT_DIR%"=="" (
    echo ERROR: PROJECT_DIR environment variable is not set
    exit /b 1
)
IF "%DATA_PATH%"=="" (
    echo ERROR: DATA_PATH environment variable is not set
    exit /b 1
)
IF NOT EXIST "%BLENDER_DIR%" (
    echo ERROR: BLENDER_DIR path does not exist: %BLENDER_DIR%
    exit /b 1
)
IF NOT EXIST "%MICROMAMBA_EXE%" (
    echo ERROR: micromamba not found at %MICROMAMBA_EXE%
    echo Please install micromamba from https://mamba.readthedocs.io/en/latest/installation.html
    exit /b 1
)

REM 检查输入视频
IF NOT EXIST "%DATA_PATH%\raw.mp4" (
    echo 错误：未找到输入视频文件 %DATA_PATH%\raw.mp4
    exit /b 1
)

REM 检查视频格式和分辨率
ffprobe -v error -select_streams v:0 -show_entries stream=width,height,duration -of csv=p=0 "%DATA_PATH%\raw.mp4" || (
    echo 错误：无法读取视频信息，请确保视频格式正确
    exit /b 1
)

REM ##################
REM # 预处理阶段     #
REM ##################

REM 添加进度显示
echo [1/3] 预处理阶段开始...

REM 将原始图像整理成3D Gaussian Splatting格式
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python preprocess_raw_images.py --data_path %DATA_PATH%
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行COLMAP重建并去畸变图像和相机
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
pushd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python convert.py -s %DATA_PATH% --camera %CAMERA% --max_size 1024
popd
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行Matte-Anything
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\matte_anything
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python calc_masks.py --data_path %DATA_PATH% --image_format png --max_size 2048
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 使用IQA分数过滤图像
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python filter_extra_images.py --data_path %DATA_PATH% --max_imgs 128
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 调整图像大小
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python resize_images.py --data_path %DATA_PATH%
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 计算方向图
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python calc_orientation_maps.py --img_path %DATA_PATH%\images_2 --mask_path %DATA_PATH%\masks_2\hair --orient_dir %DATA_PATH%\orientations_2\angles --conf_dir %DATA_PATH%\orientations_2\vars --filtered_img_dir %DATA_PATH%\orientations_2\filtered_imgs --vis_img_dir %DATA_PATH%\orientations_2\vis_imgs
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行OpenPose
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\openpose
cd %PROJECT_DIR%\ext\openpose
mkdir %DATA_PATH%\openpose
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
"%PROJECT_DIR%\ext\openpose\build\x64\Release\OpenPoseDemo.exe" --image_dir %DATA_PATH%\images_4 --scale_number 4 --scale_gap 0.25 --face --hand --display 0 --write_json %DATA_PATH%\openpose\json --write_images %DATA_PATH%\openpose\images --write_images_format jpg
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行Face-Alignment
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python calc_face_alignment.py --data_path %DATA_PATH% --image_dir "images_4"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行PIXIE
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\pixie-env
cd %PROJECT_DIR%\ext\PIXIE
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python demos\demo_fit_face.py -i %DATA_PATH%\images_4 -s %DATA_PATH%\pixie --saveParam True --lightTex False --useTex False --rasterizer_type pytorch3d
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 合并所有PIXIE预测到单个文件
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python merge_smplx_predictions.py --data_path %DATA_PATH%
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 将COLMAP相机转换为txt
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
mkdir %DATA_PATH%\sparse_txt
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
colmap model_converter --input_path %DATA_PATH%\sparse\0 --output_path %DATA_PATH%\sparse_txt --output_type TXT
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 将COLMAP相机转换为H3DS格式
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python colmap_parsing.py --path_to_scene %DATA_PATH%
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 删除原始文件以节省磁盘空间
rmdir /s /q %DATA_PATH%\input %DATA_PATH%\images %DATA_PATH%\masks %DATA_PATH%\iqa*
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 清理临时文件
del /f /s /q %DATA_PATH%\*.tmp >nul 2>&1

REM ##################
REM # 重建阶段       #
REM ##################

REM 添加进度显示
echo [2/3] 重建阶段开始...

set EXP_PATH_1=%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%

REM 运行3D Gaussian Splatting重建
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python train_gaussians.py -s %DATA_PATH% -m "%EXP_PATH_1%" -r 1 --port "888%CUDA_VISIBLE_DEVICES%" --trainable_cameras --trainable_intrinsics --use_barf --lambda_dorient 0.1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行FLAME网格拟合
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\ext\NeuralHaircut\src\multiview_optimization

set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python fit.py --conf confs\train_person_1.conf --batch_size 1 --train_rotation True --fixed_images True --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1 --data_path %DATA_PATH% --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

python fit.py --conf confs\train_person_1.conf --batch_size 4 --train_rotation True --fixed_images True --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2 --checkpoint_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1\opt_params_final --data_path %DATA_PATH% --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

python fit.py --conf confs\train_person_1_.conf --batch_size 32 --train_rotation True --train_shape True --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3 --checkpoint_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2\opt_params_final --data_path %DATA_PATH% --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 裁剪重建的场景
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python scale_scene_into_sphere.py --path_to_data %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 移除与FLAME头部网格相交的头发高斯体
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python filter_flame_intersections.py --flame_mesh_dir %DATA_PATH%\flame_fitting\%EXP_NAME_1% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000 --project_dir %PROJECT_DIR%\ext\NeuralHaircut
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 为训练视图运行渲染
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python render_gaussians.py -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --skip_test --scene_suffix "_cropped" --iteration 30000 --trainable_cameras --trainable_intrinsics --use_barf
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 获取FLAME网格头皮图
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python extract_non_visible_head_scalp.py --project_dir %PROJECT_DIR%\ext\NeuralHaircut --data_dir %DATA_PATH% --flame_mesh_dir %DATA_PATH%\flame_fitting\%EXP_NAME_1% --cams_path %DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\cameras\30000_matrices.pkl -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行潜在头发股线重建
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python train_latent_strands.py -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 --model_path_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%" --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 --trainable_cameras --trainable_intrinsics --use_barf --iterations 20000 --port "800%CUDA_VISIBLE_DEVICES%"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 运行头发股线重建
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python train_strands.py -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 --model_path_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" --start_checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 --position_lr_init 0.0000016 --position_lr_max_steps 10000 --trainable_cameras --trainable_intrinsics --use_barf --iterations 10000 --port "800%CUDA_VISIBLE_DEVICES%"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

rmdir /s /q "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\train_cropped"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM ##################
REM # 可视化阶段     #
REM ##################

REM 添加进度显示
echo [3/3] 可视化阶段开始...

REM 导出结果的股线为pkl和ply格式
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python export_curves.py --data_dir %DATA_PATH% --model_name %EXP_NAME_3% --iter 10000 --flame_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3\mesh_final.obj" --scalp_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\scalp_data\scalp.obj" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 渲染可视化
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\postprocessing
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python render_video.py --blender_path "%BLENDER_DIR%" --input_path "%DATA_PATH%" --exp_name_1 "%EXP_NAME_1%" --exp_name_3 "%EXP_NAME_3%"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 渲染股线
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python render_strands.py -s %DATA_PATH% --data_dir "%DATA_PATH%" --data_device 'cpu' --skip_test -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iteration 30000 --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" --model_hair_path "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" --checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" --checkpoint_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%\checkpoints\10000.pth" --pointcloud_path_head "%EXP_PATH_1%\point_cloud\iteration_30000\raw_point_cloud.ply" --interpolate_cameras
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)

REM 制作视频
CALL "%MICROMAMBA_EXE%" activate -p %MAMBA_ROOT_PREFIX%\envs\gaussian_splatting_hair
cd %PROJECT_DIR%\src\postprocessing
echo 正在生成最终视频...
set CUDA_VISIBLE_DEVICES=%CUDA_VISIBLE_DEVICES%
python concat_video.py --input_path "%DATA_PATH%" --exp_name_3 "%EXP_NAME_3%"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run command
    exit /b 1
)
