@echo off
setlocal enabledelayedexpansion

REM 清理旧的资源目录
IF EXIST "resource" (
    echo 清理旧的资源目录...
    rmdir /s /q "resource"
)

REM 清理错误路径的资源
IF EXIST "NeuralHaircut" rmdir /s /q "NeuralHaircut"
IF EXIST "Matte-Anything" rmdir /s /q "Matte-Anything"
IF EXIST "openpose" rmdir /s /q "openpose"
IF EXIST "hyperIQA" rmdir /s /q "hyperIQA"

REM 定义模型信息
SET "MODEL_NEURAL_HAIRCUT_NAME=Neural Haircut模型"
SET "MODEL_NEURAL_HAIRCUT_PATH=resource\NeuralHaircut\diffusion_prior\model.pt"
SET "MODEL_NEURAL_HAIRCUT_URL=1_9EOUXHayKiGH5nkrayncln3d6m1uV7f"

SET "MODEL_PIXIE_NAME=PIXIE模型数据"
SET "MODEL_PIXIE_PATH=resource\NeuralHaircut\PIXIE\pixie_data"
SET "MODEL_PIXIE_URL=1mPcGu62YPc4MdkT8FFiOCP629xsENHZf"

SET "MODEL_PIXIE_FACE_NAME=PIXIE Face模型"
SET "MODEL_PIXIE_FACE_PATH=resource\NeuralHaircut\PIXIE\pixie_data\pixie_data"
SET "MODEL_PIXIE_FACE_URL=https://github.com/yfeng95/PIXIE/raw/master/fetch_model.sh"

SET "MODEL_MATTE_NAME=Matte-Anything模型"
SET "MODEL_MATTE_PATH=resource\Matte-Anything\model.pth"
SET "MODEL_MATTE_URL=1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW"

SET "MODEL_SAM_NAME=SAM模型"
SET "MODEL_SAM_PATH=resource\Matte-Anything\sam_vit_h_4b8939.pth"
SET "MODEL_SAM_URL=https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth"

SET "MODEL_DINO_NAME=GroundingDINO模型"
SET "MODEL_DINO_PATH=resource\Matte-Anything\groundingdino_swint_ogc.pth"
SET "MODEL_DINO_URL=https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth"

SET "MODEL_OPENPOSE_NAME=OpenPose模型"
SET "MODEL_OPENPOSE_PATH=resource\openpose\models\pose\coco\pose_iter_584000.caffemodel"
SET "MODEL_OPENPOSE_URL=1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV"

SET "MODEL_HYPERIQA_NAME=hyperIQA模型"
SET "MODEL_HYPERIQA_PATH=resource\hyperIQA\pretrained\hyperIQA.pth"
SET "MODEL_HYPERIQA_URL=1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE"

REM 下载设置
SET "RETRY_COUNT=3"
SET "TIMEOUT_SECONDS=600"
SET "CURL_OPTS=--connect-timeout 30 --max-time %TIMEOUT_SECONDS% --retry %RETRY_COUNT% -L -C -"
SET "MIN_FILE_SIZE=1000000"

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
mkdir openpose\models\pose\coco 2>nul
mkdir hyperIQA\pretrained 2>nul

REM 验证已有文件
echo 正在检查已有资源文件...
SET MISSING_FILES=0
SET /A TOTAL_FILES=6
SET /A EXISTING_FILES=0
SET MISSING_LIST=

REM Neural Haircut 模型检查
IF EXIST "%MODEL_NEURAL_HAIRCUT_PATH%" (
    echo [√] %MODEL_NEURAL_HAIRCUT_NAME%已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少%MODEL_NEURAL_HAIRCUT_NAME%
    SET /A MISSING_FILES+=1
    SET MISSING_LIST=!MISSING_LIST!%MODEL_NEURAL_HAIRCUT_NAME%, 
)

REM PIXIE 模型检查
IF EXIST "%MODEL_PIXIE_PATH%" (
    echo [√] %MODEL_PIXIE_NAME%已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少%MODEL_PIXIE_NAME%
    SET /A MISSING_FILES+=1
    SET MISSING_LIST=!MISSING_LIST!%MODEL_PIXIE_NAME%, 
)

REM SAM 模型检查
IF EXIST "%MODEL_SAM_PATH%" (
    echo [√] %MODEL_SAM_NAME%已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少%MODEL_SAM_NAME%
    SET /A MISSING_FILES+=1
    SET MISSING_LIST=!MISSING_LIST!%MODEL_SAM_NAME%, 
)

REM GroundingDINO 模型检查
IF EXIST "%MODEL_DINO_PATH%" (
    echo [√] %MODEL_DINO_NAME%已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少%MODEL_DINO_NAME%
    SET /A MISSING_FILES+=1
    SET MISSING_LIST=!MISSING_LIST!%MODEL_DINO_NAME%, 
)

REM OpenPose 模型检查
IF EXIST "%MODEL_OPENPOSE_PATH%" (
    echo [√] %MODEL_OPENPOSE_NAME%已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少%MODEL_OPENPOSE_NAME%
    SET /A MISSING_FILES+=1
    SET MISSING_LIST=!MISSING_LIST!%MODEL_OPENPOSE_NAME%, 
)

REM hyperIQA 模型检查
IF EXIST "%MODEL_HYPERIQA_PATH%" (
    echo [√] %MODEL_HYPERIQA_NAME%已存在
    SET /A EXISTING_FILES+=1
) ELSE (
    echo [×] 缺少%MODEL_HYPERIQA_NAME%
    SET /A MISSING_FILES+=1
    SET MISSING_LIST=!MISSING_LIST!%MODEL_HYPERIQA_NAME%, 
)

echo.
echo 已存在 %EXISTING_FILES%/%TOTAL_FILES% 个模型文件
IF %MISSING_FILES% GTR 0 (
    echo 需要下载 %MISSING_FILES% 个模型文件
    echo 缺少的模型: !MISSING_LIST:~0,-2!
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

REM 设置代理选项（可选）
IF DEFINED HTTP_PROXY (
    SET CURL_OPTS=%CURL_OPTS% --proxy %HTTP_PROXY%
    SET REQUESTS_CA_BUNDLE=%PROJECT_DIR%\certs\cacert.pem
)

REM 下载 Neural Haircut 文件
cd resource\NeuralHaircut
IF EXIST "%MODEL_NEURAL_HAIRCUT_PATH%" (
    echo 跳过%MODEL_NEURAL_HAIRCUT_NAME%下载...
) ELSE (
    echo 正在下载%MODEL_NEURAL_HAIRCUT_NAME%...
    cd diffusion_prior
    python -m gdown "%MODEL_NEURAL_HAIRCUT_URL%"
    cd ..\..
)

REM 下载 PIXIE 文件
cd NeuralHaircut\PIXIE
IF EXIST "pixie_data.tar" (
    echo PIXIE模型已存在，跳过下载...
) ELSE (
    echo 正在下载PIXIE模型...
    python -m gdown "%MODEL_PIXIE_URL%"
    echo 正在下载PIXIE Face模型...
    curl -L "%MODEL_PIXIE_FACE_URL%" -o fetch_model.sh
    bash fetch_model.sh
)

REM 下载 Matte-Anything 文件
cd ..\..\Matte-Anything
echo 正在下载Matte-Anything文件...
IF EXIST "%MODEL_SAM_PATH%" (
    echo %MODEL_SAM_NAME%已存在，跳过下载...
) ELSE (
    echo 正在下载%MODEL_SAM_NAME%...
    curl %CURL_OPTS% -o "%MODEL_SAM_PATH%" "%MODEL_SAM_URL%"
    IF %ERRORLEVEL% NEQ 0 (
        echo 错误：下载%MODEL_SAM_NAME%失败
        exit /b 1
    )
)
IF EXIST "%MODEL_DINO_PATH%" (
    echo %MODEL_DINO_NAME%已存在，跳过下载...
) ELSE (
    echo 正在下载%MODEL_DINO_NAME%...
    curl -L --retry 5 -C - -o "%MODEL_DINO_PATH%" "%MODEL_DINO_URL%"
)
IF EXIST "%MODEL_MATTE_PATH%" (
    echo %MODEL_MATTE_NAME%已存在，跳过下载...
) ELSE (
    echo 正在下载%MODEL_MATTE_NAME%...
    python -m gdown "%MODEL_MATTE_URL%" -O model.pth
)

REM 下载 OpenPose 模型
cd ..\openpose\models\pose\coco
echo 正在下载OpenPose模型...
IF EXIST "%MODEL_OPENPOSE_PATH%" (
    echo %MODEL_OPENPOSE_NAME%已存在，跳过下载...
) ELSE (
    echo 正在下载OpenPose模型...
    python -m gdown "%MODEL_OPENPOSE_URL%" -O models.tar.gz
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
cd ..\..\..\..\..\hyperIQA\pretrained
echo 正在下载hyperIQA模型...
IF EXIST "%MODEL_HYPERIQA_PATH%" (
    echo %MODEL_HYPERIQA_NAME%已存在，跳过下载...
) ELSE (
    echo 正在下载%MODEL_HYPERIQA_NAME%...
    python -m gdown "%MODEL_HYPERIQA_URL%"
)

cd ..\..\..
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
cd %PROJECT_DIR%
SET VERIFY_FAILED=0

IF NOT EXIST "%MODEL_NEURAL_HAIRCUT_PATH%" (
    echo [×] 缺少%MODEL_NEURAL_HAIRCUT_NAME%
    SET /A VERIFY_FAILED+=1
) ELSE (
    echo [√] %MODEL_NEURAL_HAIRCUT_NAME%验证成功
)

IF NOT EXIST "%MODEL_PIXIE_PATH%" echo 警告：缺少%MODEL_PIXIE_NAME%
IF NOT EXIST "%MODEL_SAM_PATH%" echo 警告：缺少%MODEL_SAM_NAME%
IF NOT EXIST "%MODEL_DINO_PATH%" echo 警告：缺少%MODEL_DINO_NAME%
IF NOT EXIST "%MODEL_OPENPOSE_PATH%" echo 警告：缺少%MODEL_OPENPOSE_NAME%
IF NOT EXIST "%MODEL_HYPERIQA_PATH%" echo 警告：缺少%MODEL_HYPERIQA_NAME%

IF %VERIFY_FAILED% GTR 0 (
    echo.
    echo 文件完整性验证失败：%VERIFY_FAILED% 个文件缺失或不完整
    echo 请重新运行脚本下载缺失文件
    exit /b 1
) ELSE (
    echo.
    echo 文件完整性验证成功！
)
