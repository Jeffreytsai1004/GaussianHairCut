@echo off
setlocal enabledelayedexpansion

REM 设置当前目录
SET PROJECT_DIR=%~dp0
cd %PROJECT_DIR%

REM 检查7-Zip是否安装
where 7z >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo 错误：未找到7-Zip
    echo 请从 https://7-zip.org/ 下载并安装7-Zip
    echo 并将其添加到系统环境变量PATH中
    exit /b 1
)

REM 检查Python是否安装
python --version >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo 错误：未找到Python
    echo 请安装Python并将其添加到系统环境变量PATH中
    exit /b 1
)

REM 更新pip
python -m pip install --upgrade pip

REM 检查gdown是否已安装
python -c "import gdown" >nul 2>nul
IF %ERRORLEVEL% EQU 0 (
    echo gdown已安装，跳过安装步骤...
) ELSE (
    REM 安装gdown
    echo 正在安装gdown...
    python -m pip install --user gdown --upgrade
    python -m pip install --user requests --upgrade
    IF %ERRORLEVEL% NEQ 0 (
        echo 错误：gdown安装失败
        echo 请检查网络连接后重试
        exit /b 1
    )
)

REM 添加Python Scripts目录到PATH
for /f "tokens=*" %%i in ('python -c "import sys; print(sys.executable)"') do set PYTHON_PATH=%%i
set PYTHON_SCRIPTS_PATH=%PYTHON_PATH:python.exe=Scripts%
set PYTHON_USER_SCRIPTS=%USERPROFILE%\AppData\Roaming\Python\Python3*\Scripts
set PATH=%PYTHON_SCRIPTS_PATH%;%PYTHON_USER_SCRIPTS%;%PATH%

REM 验证gdown是否可用
echo 正在验证gdown安装...
python -c "import gdown" >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo 错误：gdown安装验证失败
    echo 请重新运行脚本
    exit /b 1
)
echo gdown安装成功！
echo.

REM 创建resource目录结构
mkdir resource 2>nul
cd resource
mkdir NeuralHaircut\diffusion_prior 2>nul
mkdir NeuralHaircut\PIXIE 2>nul
mkdir Matte-Anything 2>nul
mkdir openpose\models 2>nul
mkdir hyperIQA\pretrained 2>nul

REM 验证已有文件
echo 正在检查已有资源文件...
SET MISSING_FILES=0
SET /A TOTAL_FILES=6
SET /A EXISTING_FILES=0

IF EXIST "NeuralHaircut\diffusion_prior\model.pt" (
    echo [√] Neural Haircut模型已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少Neural Haircut模型
    SET /A MISSING_FILES+=1
)

IF EXIST "NeuralHaircut\PIXIE\pixie_data" (
    echo [√] PIXIE模型数据已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少PIXIE模型数据
    SET /A MISSING_FILES+=1
)

IF EXIST "Matte-Anything\sam_vit_h_4b8939.pth" (
    echo [√] SAM模型已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少SAM模型
    SET /A MISSING_FILES+=1
)

IF EXIST "Matte-Anything\groundingdino_swint_ogc.pth" (
    echo [√] GroundingDINO模型已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少GroundingDINO模型
    SET /A MISSING_FILES+=1
)

IF EXIST "openpose\models\pose\coco" (
    echo [√] OpenPose模型已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少OpenPose模型
    SET /A MISSING_FILES+=1
)

IF EXIST "hyperIQA\pretrained\hyperIQA.pth" (
    echo [√] hyperIQA模型已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少hyperIQA模型
    SET /A MISSING_FILES+=1
)

echo.
echo 已存在 %EXISTING_FILES%/%TOTAL_FILES% 个模型文件
IF %MISSING_FILES% GTR 0 (
    echo 需要下载 %MISSING_FILES% 个模型文件
    echo.
    echo ************************************************************
    echo *                  开始下载所需资源文件                     *
    echo *            下载时间取决于您的网络连接速度                 *
    echo *                    请耐心等待...                         *
    echo ************************************************************
) ELSE (
    echo 所有模型文件已存在，无需下载
    exit /b 0
)

REM 设置下载重试次数和超时时间
SET RETRY_COUNT=3
SET TIMEOUT_SECONDS=600
SET CURL_OPTS=--connect-timeout 30 --max-time %TIMEOUT_SECONDS% --retry %RETRY_COUNT% -L -C -

REM 设置代理选项（可选）
IF DEFINED HTTP_PROXY (
    SET CURL_OPTS=%CURL_OPTS% --proxy %HTTP_PROXY%
    SET REQUESTS_CA_BUNDLE=%PROJECT_DIR%\certs\cacert.pem
)

REM 添加文件大小检查
SET MIN_FILE_SIZE=1000000  REM 1MB

REM 下载 Neural Haircut 文件
cd NeuralHaircut
IF EXIST "diffusion_prior\model.pt" (
    echo 跳过Neural Haircut模型下载...
) ELSE (
    echo 正在下载Neural Haircut文件...
    python -m gdown --folder "https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8" --continue
)

cd diffusion_prior
IF EXIST "model.pt" (
    echo 跳过扩散先验模型下载...
) ELSE (
    echo 正在下载扩散先验模型...
    python -m gdown "1_9EOUXHayKiGH5nkrayncln3d6m1uV7f"
)

cd ..\PIXIE
IF EXIST "pixie_data.tar" (
    echo PIXIE模型已存在，跳过下载...
) ELSE (
    echo 正在下载PIXIE模型...
    python -m gdown "1mPcGu62YPc4MdkT8FFiOCP629xsENHZf"
    
    REM 使用7-Zip解压tar.gz文件
    IF NOT EXIST pixie_data.tar.gz (
        echo 错误：下载pixie_data.tar.gz失败
        exit /b 1
    )
    7z x pixie_data.tar.gz -y
    7z x pixie_data.tar -y
    del pixie_data.tar.gz
    del pixie_data.tar
)

REM 下载 Matte-Anything 文件
cd ..\..\Matte-Anything
echo 正在下载Matte-Anything文件...
IF EXIST "sam_vit_h_4b8939.pth" (
    echo SAM模型已存在，跳过下载...
) ELSE (
    echo 正在下载SAM模型...
    curl %CURL_OPTS% -o sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
    IF %ERRORLEVEL% NEQ 0 (
        echo 错误：下载SAM模型失败
        exit /b 1
    )
)
IF EXIST "groundingdino_swint_ogc.pth" (
    echo GroundingDINO模型已存在，跳过下载...
) ELSE (
    echo 正在下载GroundingDINO模型...
    curl -L --retry 5 -C - -o groundingdino_swint_ogc.pth https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
)
IF EXIST "model.pth" (
    echo Matte-Anything模型已存在，跳过下载...
) ELSE (
    echo 正在下载Matte-Anything模型...
    python -m gdown "1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW" -O model.pth
)

REM 下载 OpenPose 模型
cd ..\openpose
echo 正在下载OpenPose模型...
IF EXIST "models\pose_iter_584000.caffemodel" (
    echo OpenPose模型已存在，跳过下载...
) ELSE (
    echo 正在下载OpenPose模型...
    python -m gdown "1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV" -O models.tar.gz
    IF NOT EXIST models.tar.gz (
        echo 错误：下载models.tar.gz失败
        exit /b 1
    )
    7z x models.tar.gz -y
    7z x models.tar -y -omodels
    del models.tar.gz
    del models.tar
)

REM 下载 hyperIQA 模型
cd ..\hyperIQA\pretrained
echo 正在下载hyperIQA模型...
IF EXIST "hyperIQA.pth" (
    echo hyperIQA模型已存在，跳过下载...
) ELSE (
    echo 正在下载hyperIQA模型...
    python -m gdown "1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE"
)

cd ..\..
echo.
IF %ERRORLEVEL% EQU 0 (
    echo ************************************************************
    echo *                    下载任务已完成                         *
    echo *              所有资源文件已下载到resource目录             *
    echo ************************************************************
) ELSE (
    echo ************************************************************
    echo *                    下载任务未完成                         *
    echo *                  请检查以上错误信息                       *
    echo ************************************************************
    exit /b 1
)

REM 验证下载的文件完整性
echo 正在验证下载文件...
cd %PROJECT_DIR%\resource
SET VERIFY_FAILED=0

IF NOT EXIST "NeuralHaircut\diffusion_prior\model.pt" (
    echo [×] 缺少扩散先验模型文件
    SET /A VERIFY_FAILED+=1
) ELSE (
    echo [√] 扩散先验模型文件验证成功
)

IF NOT EXIST "NeuralHaircut\PIXIE\pixie_data" echo 警告：缺少PIXIE模型数据
IF NOT EXIST "Matte-Anything\sam_vit_h_4b8939.pth" echo 警告：缺少SAM模型文件
IF NOT EXIST "Matte-Anything\groundingdino_swint_ogc.pth" echo 警告：缺少GroundingDINO模型文件
IF NOT EXIST "openpose\models\pose\coco" echo 警告：缺少OpenPose姿态模型
IF NOT EXIST "hyperIQA\pretrained\hyperIQA.pth" echo 警告：缺少hyperIQA模型文件

IF %VERIFY_FAILED% GTR 0 (
    echo.
    echo 文件完整性验证失败：%VERIFY_FAILED% 个文件缺失或不完整
    echo 请重新运行脚本下载缺失文件
    exit /b 1
) ELSE (
    echo.
    echo 文件完整性验证成功！
)
