#!/bin/bash

#cd dist_electron
rm -fr ./igel_package
mkdir -p ./igel_package/imi_electron/usr/bin
mkdir -p ./igel_package/imi_electron/userhome/.config
touch ./igel_package/imi_electron/userhome/.config/IMI_Config_Changer.json
cp ./imi_electron_init_script ./igel_package
cp ./dist_electron/imi_electron-0.1.0.AppImage ./igel_package/imi_electron/usr/bin/
cd ./igel_package
tar -cjSf ../imi_electron.tar.bz2 *