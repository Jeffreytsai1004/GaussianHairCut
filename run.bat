@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
Echo ============= SETTING UP GLOBAL VARIABLES =============
@CALL SET PROJECT_DIR=%~dp0
@CALL SET RESOURCE_DIR=%PROJECT_DIR%resource
@CALL SET CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
@CALL SET NVCC_PATH=%CUDA_HOME%\bin\nvcc.exe
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6
@CALL SET VS_DIR=C:\Program Files\Microsoft Visual Studio\2022\Professional
@CALL SET VS_VCVARS=%VS_DIR%\VC\Auxiliary\Build\vcvars64.bat
@CALL SET DATA_PATH=%PROJECT_DIR%raw
@CALL SET EXT_DIR=%PROJECT_DIR%ext
@CALL SET ENV_DIR=%PROJECT_DIR%envs
@CALL SET CUDA_DIR=%CUDA_HOME%
@CALL SET CUDA_PATH=%CUDA_HOME%
@CALL SET CUDA_PATH_V11_8=%CUDA_HOME%
@CALL set PYTHONDONTWRITEBYTECODE=1
@CALL set GDOWN_CACHE=%PROJECT_DIR%cache\gdown
@CALL set TORCH_HOME=%PROJECT_DIR%cache\torch
@CALL set HF_HOME=%PROJECT_DIR%cache\huggingface
Echo PROJECT_DIR: %PROJECT_DIR%
Echo BLENDER_DIR: %BLENDER_DIR%
Echo DATA_PATH: %DATA_PATH%
Echo CUDA_HOME: %CUDA_HOME%
Echo CUDA_DIR: %CUDA_DIR%
Echo ENV_DIR: %ENV_DIR%
Echo EXT_DIR: %EXT_DIR%
Echo RESOURCE_DIR: %RESOURCE_DIR%
Echo VS_DIR: %VS_DIR%
Echo VS_VCVARS: %VS_VCVARS%
Echo GDOWN_CACHE: %GDOWN_CACHE%
Echo TORCH_HOME: %TORCH_HOME%
Echo HF_HOME: %HF_HOME%
@CALL SET PATH=%CUDA_HOME%\bin;%PROJECT_DIR%condabin;%PATH%

@CALL SET  GPU="0"
@CALL SET  CAMERA="PINHOLE"
@CALL SET  EXP_NAME_1="stage1"
@CALL SET  EXP_NAME_2="stage2"
@CALL SET  EXP_NAME_3="stage3"

REM ##################
REM # 预处理阶段     #
REM ##################

REM 将原始图像整理成3D Gaussian Splatting格式
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python preprocess_raw_images.py ^
    --data_path %DATA_PATH%

REM 运行COLMAP重建并去畸变图像和相机
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python convert.py -s %DATA_PATH% ^
    --camera %CAMERA% --max_size 1024

REM 运行Matte-Anything
@CALL "%~dp0condabin\micromamba.bat" activate matte_anything
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python calc_masks.py ^
    --data_path %DATA_PATH% --image_format png --max_size 2048

REM 使用IQA分数过滤图像
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python filter_extra_images.py ^
    --data_path %DATA_PATH% --max_imgs 128

REM 调整图像大小
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python resize_images.py --data_path %DATA_PATH%

REM 计算方向图
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python calc_orientation_maps.py ^
    --img_path %DATA_PATH%\images_2 ^
    --mask_path %DATA_PATH%\masks_2\hair ^
    --orient_dir %DATA_PATH%\orientations_2\angles ^
    --conf_dir %DATA_PATH%\orientations_2\vars ^
    --filtered_img_dir %DATA_PATH%\orientations_2\filtered_imgs ^
    --vis_img_dir %DATA_PATH%\orientations_2\vis_imgs

REM 运行OpenPose
@CALL "%~dp0condabin\micromamba.bat" deactivate && cd %PROJECT_DIR%\ext\openpose
@CALL "%~dp0condabin\micromamba.bat" activate openpose
@CALL mkdir %DATA_PATH%\openpose
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL "%PROJECT_DIR%\ext\openpose\build\x64\Release\OpenPoseDemo.exe" ^
    --image_dir %DATA_PATH%\images_4 ^
    --scale_number 4 --scale_gap 0.25 --face --hand --display 0 ^
    --write_json %DATA_PATH%\openpose\json ^
    --write_images %DATA_PATH%\openpose\images --write_images_format jpg

REM 运行Face-Alignment
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python calc_face_alignment.py ^
    --data_path %DATA_PATH% --image_dir "images_4"

REM 运行PIXIE
@CALL "%~dp0condabin\micromamba.bat" activate pixie-env
@CALL cd %PROJECT_DIR%\ext\PIXIE
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python demos\demo_fit_face.py ^
    -i %DATA_PATH%\images_4 -s %DATA_PATH%\pixie ^
    --saveParam True --lightTex False --useTex False ^
    --rasterizer_type pytorch3d

REM 合并所有PIXIE预测到单个文件
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python merge_smplx_predictions.py ^
    --data_path %DATA_PATH%

REM 将COLMAP相机转换为txt
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL mkdir %DATA_PATH%\sparse_txt
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL colmap model_converter ^
    --input_path %DATA_PATH%\sparse\0 ^
    --output_path %DATA_PATH%\sparse_txt --output_type TXT

REM 将COLMAP相机转换为H3DS格式
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python colmap_parsing.py ^
    --path_to_scene %DATA_PATH%

REM 删除原始文件以节省磁盘空间
@CALL rmdir /s /q %DATA_PATH%\input %DATA_PATH%\images %DATA_PATH%\masks %DATA_PATH%\iqa*

REM ##################
REM # 重建阶段       #
REM ##################

@CALL SET EXP_PATH_1=%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%

REM 运行3D Gaussian Splatting重建
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python train_gaussians.py ^
    -s %DATA_PATH% -m "%EXP_PATH_1%" -r 1 --port "888%GPU%" ^
    --trainable_cameras --trainable_intrinsics --use_barf ^
    --lambda_dorient 0.1

REM 运行FLAME网格拟合
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\src\multiview_optimization

@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python fit.py --conf confs\train_person_1.conf ^
    --batch_size 1 --train_rotation True --fixed_images True ^
    --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1 ^
    --data_path %DATA_PATH% ^
    --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl

@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python fit.py --conf confs\train_person_1.conf ^
    --batch_size 4 --train_rotation True --fixed_images True ^
    --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2 ^
    --checkpoint_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1\opt_params_final ^
    --data_path %DATA_PATH% ^
    --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl

@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python fit.py --conf confs\train_person_1_.conf ^
    --batch_size 32 --train_rotation True --train_shape True ^
    --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3 ^
    --checkpoint_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2\opt_params_final ^
    --data_path %DATA_PATH% ^
    --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl

REM 裁剪重建的场景
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python scale_scene_into_sphere.py ^
    --path_to_data %DATA_PATH% ^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000

REM 移除与FLAME头部网格相交的头发高斯体
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python filter_flame_intersections.py ^
    --flame_mesh_dir %DATA_PATH%\flame_fitting\%EXP_NAME_1% ^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000 ^
    --project_dir %PROJECT_DIR%\ext\NeuralHaircut

REM 为训练视图运行渲染
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python render_gaussians.py ^
    -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" ^
    --skip_test --scene_suffix "_cropped" --iteration 30000 ^
    --trainable_cameras --trainable_intrinsics --use_barf

REM 获取FLAME网格头皮图
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python extract_non_visible_head_scalp.py ^
    --project_dir %PROJECT_DIR%\ext\NeuralHaircut --data_dir %DATA_PATH% ^
    --flame_mesh_dir %DATA_PATH%\flame_fitting\%EXP_NAME_1% ^
    --cams_path %DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\cameras\30000_matrices.pkl ^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%"

REM 运行潜在头发股线重建
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src   
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python train_latent_strands.py ^
    -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 ^
    --model_path_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%" ^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^
    --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" ^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" ^
    --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 ^
    --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 ^
    --trainable_cameras --trainable_intrinsics --use_barf ^
    --iterations 20000 --port "800%GPU%"

REM 运行头发股线重建
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src   
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python train_strands.py ^
    -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 ^
    --model_path_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" ^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^
    --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" ^
    --start_checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" ^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" ^
    --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 ^
    --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 ^
    --position_lr_init 0.0000016 --position_lr_max_steps 10000 ^
    --trainable_cameras --trainable_intrinsics --use_barf ^
    --iterations 10000 --port "800%GPU%"

@CALL rmdir /s /q "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\train_cropped"

REM ##################
REM # 可视化阶段     #
REM ##################

REM 导出结果的股线为pkl和ply格式
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src\preprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python export_curves.py ^
    --data_dir %DATA_PATH% --model_name %EXP_NAME_3% --iter 10000 ^
    --flame_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3\mesh_final.obj" ^
    --scalp_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\scalp_data\scalp.obj" ^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml"

REM 渲染可视化
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src\postprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python render_video.py ^
    --blender_path "%BLENDER_DIR%" --input_path "%DATA_PATH%" ^
    --exp_name_1 "%EXP_NAME_1%" --exp_name_3 "%EXP_NAME_3%"

REM 渲染股线
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src   
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python render_strands.py ^
    -s %DATA_PATH% --data_dir "%DATA_PATH%" --data_device 'cpu' --skip_test ^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iteration 30000 ^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^
    --model_hair_path "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" ^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" ^
    --checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" ^
    --checkpoint_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%\checkpoints\10000.pth" ^
    --pointcloud_path_head "%EXP_PATH_1%\point_cloud\iteration_30000\raw_point_cloud.ply" ^
    --interpolate_cameras

REM 制作视频
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair && cd %PROJECT_DIR%\src\postprocessing
@CALL SET CUDA_VISIBLE_DEVICES=%GPU% && @CALL python concat_video.py ^
    --input_path "%DATA_PATH%" --exp_name_3 "%EXP_NAME_3%"

