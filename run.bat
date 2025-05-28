@ECHO OFF
SETLOCAL EnableDelayedExpansion

ECHO .
ECHO ==========================================================
ECHO    Set environment variables for micromamba and tools
ECHO ==========================================================
SET PROJECT_DIR_ORIGIN=%~dp0
SET PROJECT_DIR=%PROJECT_DIR_ORIGIN:~0,-1%
CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%PROJECT_DIR%"
SET PROJECT_DIR_ORIGIN=%~dp0
SET PROJECT_DIR=%PROJECT_DIR_ORIGIN:~0,-1%
SET MAMBA_ROOT_PREFIX=%PROJECT_DIR%
SET ROOT_PREFIX=%PROJECT_DIR%
SET DATA_PATH=%PROJECT_DIR%\data
SET PKGS_PATH=%PROJECT_DIR%\pkgs
SET ENV_PATH=%PROJECT_DIR%\envs
SET EXT_PATH=%PROJECT_DIR%\ext
SET GDOWN_CACHE=%PROJECT_DIR%\cache\gdown
SET TORCH_HOME=%PROJECT_DIR%\cache\torch
SET HF_HOME=%PROJECT_DIR%\cache\huggingface
SET PYTHONDONTWRITEBYTECODE=1
SET DISTUTILS_USE_SDK=1
SET "COLMAP_PATH=C:\Program Files\Colmap\bin"
SET "CMAKE_PATH=C:\Program Files\CMake\bin"
SET "FFMPEG_PATH=C:\Program Files\FFmpeg\bin"
SET "BLENDER_PATH=C:\Program Files\Blender Foundation\Blender 3.6"
SET "CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
SET "VCVARS_DIR=D:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build"

ECHO .
ECHO micromamba config list:
CALL "%~dp0micromamba.exe" config list

ECHO Killing any running micromamba processes...
taskkill /F /IM micromamba.exe /T 2>NUL
taskkill /F /IM conda.exe /T 2>NUL
taskkill /F /IM python.exe /T 2>NUL
timeout /t 2 /nobreak >NUL

ECHO Set stage variables...
SET "GPU=0"
SET "EXP_NAME_1=stage1"
SET "EXP_NAME_2=stage2"
SET "EXP_NAME_3=stage3"

ECHO #################
ECHO # Preprocessing #
ECHO #################

ECHO Convert original images to 3D Gaussian Splatting format...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL CUDA_VISIBLE_DEVICES="%GPU%" python preprocess_raw_images.py --data_path "%DATA_PATH%"

ECHO Run COLMAP reconstruction and camera calibration...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src"
CALL python convert.py -s "%DATA_PATH%" --camera "OPENCV" --max_size 1024

ECHO Run Matte-Anything...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate matte_anything
CD "%PROJECT_DIR%\src\preprocessing"
CALL python calc_masks.py --data_path "%DATA_PATH%" --image_format png --max_size 2048

ECHO Filter images using IQA scores...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python filter_extra_images.py --data_path "%DATA_PATH%" --max_imgs 128

ECHO Resize images...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python resize_images.py --data_path "%DATA_PATH%"

ECHO Calculate orientation maps...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python calc_orientation_maps.py ^^
    --img_path "%DATA_PATH%\images_2" ^^
    --mask_path "%DATA_PATH%\masks_2\hair" ^^
    --orient_dir "%DATA_PATH%\orientations_2\angles" ^^
    --conf_dir "%DATA_PATH%\orientations_2\vars" ^^
    --filtered_img_dir "%DATA_PATH%\orientations_2\filtered_imgs" ^^
    --vis_img_dir "%DATA_PATH%\orientations_2\vis_imgs"

ECHO Run OpenPose...
CALL condabin\micromamba.bat activate openpose
CD "%PROJECT_DIR%\ext\openpose"
IF NOT EXIST "%DATA_PATH%\openpose" mkdir "%DATA_PATH%\openpose"
CALL "%PROJECT_DIR%\ext\openpose\build\bin\OpenPoseDemo.exe" ^^
    --image_dir "%DATA_PATH%\images_4" ^^
    --scale_number 4 --scale_gap 0.25 --face --hand --display 0 ^^
    --write_json "%DATA_PATH%\openpose\json" ^^
    --write_images "%DATA_PATH%\openpose\images" --write_images_format jpg

ECHO Run Face-Alignment...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python calc_face_alignment.py ^^
    --data_path "%DATA_PATH%" --image_dir "images_4"

ECHO Run PIXIE...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate pixie-env
CD "%PROJECT_DIR%\ext\PIXIE"
CALL micromamba run -n pixie-env python demos\demo_fit_face.py ^^
    -i "%DATA_PATH%\images_4" -s "%DATA_PATH%\pixie" ^^
    --saveParam True --lightTex False --useTex False ^^
    --rasterizer_type pytorch3d

ECHO Merge all PIXIE predictions into a single file...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python merge_smplx_predictions.py --data_path "%DATA_PATH%"

ECHO Convert COLMAP cameras to txt format...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
IF NOT EXIST "%DATA_PATH%\sparse_txt" mkdir "%DATA_PATH%\sparse_txt"
CALL colmap model_converter ^^
    --input_path "%DATA_PATH%\sparse\0" ^^
    --output_path "%DATA_PATH%\sparse_txt" --output_type TXT

ECHO Convert COLMAP cameras to H3DS format...
CALL condabin\micromamba.bat deactivate
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python colmap_parsing.py --path_to_scene "%DATA_PATH%"

ECHO Delete original files to save disk space...
IF EXIST "%DATA_PATH%\input" rmdir /s /q "%DATA_PATH%\input"
IF EXIST "%DATA_PATH%\images" rmdir /s /q "%DATA_PATH%\images"
IF EXIST "%DATA_PATH%\masks" rmdir /s /q "%DATA_PATH%\masks"
IF EXIST "%DATA_PATH%\iqa*" del /q "%DATA_PATH%\iqa*"

ECHO ##################
ECHO # Reconstruction #
ECHO ##################

SET "EXP_PATH_1=%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%"

ECHO Run 3D Gaussian Splatting...
CD "%PROJECT_DIR%\src"
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CALL micromamba run -n gaussian_splatting_hair python train_gaussians.py ^^
    -s "%DATA_PATH%" -m "%EXP_PATH_1%" -r 1 --port "888%GPU%" ^^
    --trainable_cameras --trainable_intrinsics --use_barf ^^
    --lambda_dorient 0.1

ECHO Run FLAME mesh fitting...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\ext\NeuralHaircut\src\multiview_optimization"

CALL micromamba run -n gaussian_splatting_hair python fit.py --conf confs/train_person_1.conf ^^
    --batch_size 1 --train_rotation True --fixed_images True ^^
    --save_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1" ^^
    --data_path "%DATA_PATH%" ^^
    --fitted_camera_path "%EXP_PATH_1%\cameras\30000_matrices.pkl"

CALL micromamba run -n gaussian_splatting_hair python fit.py --conf confs/train_person_1.conf ^^
    --batch_size 4 --train_rotation True --fixed_images True ^^
    --save_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2" ^^
    --checkpoint_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1\opt_params_final" ^^
    --data_path "%DATA_PATH%" ^^
    --fitted_camera_path "%EXP_PATH_1%\cameras\30000_matrices.pkl"

CALL micromamba run -n gaussian_splatting_hair python fit.py --conf confs/train_person_1_.conf ^^
    --batch_size 32 --train_rotation True --train_shape True ^^
    --save_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3" ^^
    --checkpoint_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2\opt_params_final" ^^
    --data_path "%DATA_PATH%" ^^
    --fitted_camera_path "%EXP_PATH_1%\cameras\30000_matrices.pkl"

ECHO Crop reconstruction scene...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python scale_scene_into_sphere.py ^^
    --path_to_data "%DATA_PATH%" ^^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000

ECHO Remove hair Gaussian distributions intersecting with FLAME head mesh...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python filter_flame_intersections.py ^^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000 ^^
    --project_dir "%PROJECT_DIR%\ext\NeuralHaircut"

ECHO Run training view rendering...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src"
CALL micromamba run -n gaussian_splatting_hair python render_gaussians.py ^^
    -s "%DATA_PATH%" -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" ^^
    --skip_test --scene_suffix "_cropped" --iteration 30000 ^^
    --trainable_cameras --trainable_intrinsics --use_barf

ECHO Get FLAME mesh scalp...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python extract_non_visible_head_scalp.py ^^
    --project_dir "%PROJECT_DIR%\ext\NeuralHaircut" --data_dir "%DATA_PATH%" ^^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^^
    --cams_path "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\cameras\30000_matrices.pkl" ^^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%"

ECHO Run latent strand reconstruction...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src"
CALL micromamba run -n gaussian_splatting_hair python train_latent_strands.py ^^
    -s "%DATA_PATH%" -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 ^^
    --model_path_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%" ^^^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^^
    --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" ^^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" ^^
    --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 ^^
    --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 ^^
    --trainable_cameras --trainable_intrinsics --use_barf ^^
    --iterations 20000 --port "800%GPU%"

ECHO Run strand reconstruction...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src"
CALL micromamba run -n gaussian_splatting_hair python train_strands.py ^^
    -s "%DATA_PATH%" -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 ^^
    --model_path_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" ^^^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^^
    --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" ^^
    --start_checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" ^^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" ^^
    --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 ^^
    --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 ^^
    --position_lr_init 0.0000016 --position_lr_max_steps 10000 ^^
    --trainable_cameras --trainable_intrinsics --use_barf ^^
    --iterations 10000 --port "800%GPU%"

IF EXIST "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\train_cropped" rmdir /s /q "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\train_cropped"

ECHO ##################
ECHO # Visualization #
ECHO ##################

ECHO Export generated strands as pkl and ply files
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\preprocessing"
CALL micromamba run -n gaussian_splatting_hair python export_curves.py ^^
    --data_dir "%DATA_PATH%" --model_name "%EXP_NAME_3%" --iter 10000 ^^
    --flame_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3\mesh_final.obj" ^^
    --scalp_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\scalp_data\scalp.obj" ^^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml"

ECHO Render visualization...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src\postprocessing"
CALL micromamba run -n gaussian_splatting_hair python render_video.py ^^
    --blender_path "%BLENDER_PATH%" --input_path "%DATA_PATH%" ^^
    --exp_name_1 "%EXP_NAME_1%" --exp_name_3 "%EXP_NAME_3%"

ECHO Render strands...
CALL condabin\micromamba.bat activate gaussian_splatting_hair
CD "%PROJECT_DIR%\src"
CALL micromamba run -n gaussian_splatting_hair python render_strands.py ^^
    -s "%DATA_PATH%" --data_dir "%DATA_PATH%" --data_device "cpu" --skip_test ^^
    -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iteration 30000 ^^^
    --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" ^^
    --model_hair_path "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" ^^
    --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" ^^
    --checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" ^^
    --checkpoint_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%\checkpoints\10000.pth" ^^
    --pointcloud_path_head "%EXP_PATH_1%\point_cloud\iteration_30000\raw_point_cloud.ply" ^^
    --interpolate_cameras

ECHO Make video...
CD "%PROJECT_DIR%\src\postprocessing"
CALL micromamba run -n gaussian_splatting_hair python concat_video.py ^^
    --input_path "%DATA_PATH%" --exp_name_3 "%EXP_NAME_3%"

ECHO.
ECHO Reconstruction process completed!
ECHO Results saved in %DATA_PATH% directory
