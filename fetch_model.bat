@echo off

mkdir .\resource\PIXIE\data

echo.
echo You need to register at https://smpl-x.is.tue.mpg.de
set /P username_smplx="Username (SMPL-X): "
set /P password_smplx="Password (SMPL-X): "

echo Downloading SMPL-X 2020 (neutral SMPL-X model)...
curl -o ".\resource\PIXIE\data\SMPLX_NEUTRAL_2020.npz" --post-fields "username=%username_smplx%&password=%password_smplx%" "https://download.is.tue.mpg.de/download.php?domain=smplx&sfile=SMPLX_NEUTRAL_2020.npz&resume=1" --insecure --continue

echo.
echo You need to register at https://pixie.is.tue.mpg.de/
set /P username_pixie="Username (PIXIE): "
set /P password_pixie="Password (PIXIE): "

echo Downloading PIXIE pretrained model...
curl -o ".\resource\PIXIE\data\pixie_model.tar" --post-fields "username=%username_pixie%&password=%password_pixie%" "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=pixie_model.tar&resume=1" --insecure --continue

echo Downloading PIXIE utilities...
curl -o ".\resource\PIXIE\data\utilities.zip" --post-fields "username=%username_pixie%&password=%password_pixie%" "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=utilities.zip&resume=1" --insecure --continue

cd data
echo Extracting utilities.zip...
powershell -Command "Expand-Archive -Path 'utilities.zip' -DestinationPath '.'"
echo Extraction complete.

echo.
echo Model download and extraction completed.
pause 