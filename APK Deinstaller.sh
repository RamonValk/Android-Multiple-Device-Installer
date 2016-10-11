#!/bin/bash
# Multiple Device Installer - Ramon Valk

echo "Hey whatsup, You're running $0, are you sure you want to proceed?"

read -r -p "[y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    #set permissions
    chmod 755 "$0"

    #data function for reentering apk info
    function setData {
     
     read -p "We are going to need the path to the APK file you want to remove (APK must be in the same directory and can't have spaces, also the package name must be the same as the installed version!) : " apkD
     echo "\nChecking for attached devices..."
     inputDevicesString=$(./data/adb devices | grep -v List | grep device | perl -p -e 's/(\w+)\s.*/\1/')
     inputDevicesArray=(`echo ${inputDevicesString}`);
     deviceNMR=$(echo ${#inputDevicesArray[@]})
     echo "\nFound $deviceNMR device(s)!"

     #gettting model number via getprop
     echo "Device name(s) : "
     for (( i = 0; i < $deviceNMR; i++ )); do
        ./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model
         
     done
     sleep 0.5
    
     echo "\n Okey, you entered $apkD as your path and you attached $deviceNMR device(s). \nIs this correct?"
     read -r -p "[y/N]" dataResponse
    if [[ $dataResponse =~ ^[nN]$ ]]; then
        setData
    fi
    echo "\nOkey, let's proceed.\n"
     }
    setData
    sleep 2

    #get package name via aapt
    aaptDump=$(./data/aapt dump badging $apkD | grep package:\ name)
    echo "Getting package name from apk..."
    packageName=$(echo $aaptDump| cut -d"'" -f 2)
    sleep 1.5
    echo "\nPackage name found : $packageName\n"

    #uninstall apk via adb
    echo "Removing apk...\n"
    for (( i = 0; i < $deviceNMR; i++ )); do
        ./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model
        ./data/adb -s ${inputDevicesArray[$i]} uninstall $packageName
        echo "\n" 
    done
    sleep 1

    echo "\nWe are done here. 👋🏼  \n"

else
    echo "\nWell bye 👋🏼  \n"
    sleep 2.5
    exit
fi


