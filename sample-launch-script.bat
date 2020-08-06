@echo off

set app_dir=%HOMEDRIVE%%HOMEPATH%\Documents\GitHub\automate-jamstack

echo Changing to app directory: %app_dir%
cd %app_dir%

REM Build docker image if it doesn't exist

docker images | findstr "poshjosh/automate-jamstack" && set res="y" || set res="n"
if %res% == "n" (
    echo Building image poshjosh/automate-jamstack
    docker build -t poshjosh/automate-jamstack .
)

REM Stop docker container if it is running

docker ps -a | findstr "poshjosh-automate-jamstack" && set res="y" || set res="n"
if %res% == "y" (
    echo Stopping container poshjosh-automate-jamstack
    docker container stop poshjosh-automate-jamstack
    echo Waiting 7 seconds
    timeout /t 7
)

echo Running image poshjosh/automate-jamstack

echo Using environment file %app_dir%\app\sites\chinomsoikwuagwu.com.env

docker run --name poshjosh-automate-jamstack --rm -v "%cd%/app":/app ^
    --env-file %app_dir%\app\sites\chinomsoikwuagwu.com.env ^
    -u 0 -p 8000:8000 -e APP_PORT=8000 poshjosh/automate-jamstack

docker system prune -f

echo DONE
set /p USER_EXIT_KEY=Press any key to exit

REM Good info on avoiding reinstall of dependencies
REM https://realguess.net/2017/06/01/avoiding-dependencies-reinstall-when-building-nodejs-docker-image/
