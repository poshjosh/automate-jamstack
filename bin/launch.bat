@echo off

set app_dir="%HOMEDRIVE%%HOMEPATH%\Documents\GitHub\automate-jamstack"
echo '...Changing to root directory/folder'

cd %app_dir%
echo %cd%

REM Build docker image poshjosh/automate-jamstack if it doesn't exist

docker container stop poshjosh-automate-jamstack

docker images | findstr "poshjosh/automate-jamstack" && set res="y" || set res="n"
if %res% == "n" (
    echo 'Building image poshjosh/automate-jamstack'
    docker build -t poshjosh/automate-jamstack .
)

echo 'Running image poshjosh/automate-jamstack'

REM    -v :/sites/default-site/node_modules -> To hide to node modules volume -> Test this

docker run --name poshjosh-automate-jamstack --rm -v "%cd%/sites":/sites ^
    --env-file %app_dir%\sites\default-site.env ^
    -u 0 -p 8000:8000 -e APP_PORT=8000 poshjosh/automate-jamstack

docker system prune -f

echo DONE
set /p USER_EXIT_KEY=Press any key to exit

REM Good info on avoiding reinstall of dependencies
REM https://realguess.net/2017/06/01/avoiding-dependencies-reinstall-when-building-nodejs-docker-image/
