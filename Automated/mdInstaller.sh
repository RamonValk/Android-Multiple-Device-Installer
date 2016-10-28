#!/bin/bash
# Multiple Device Installer - Ramon Valk
version="1.1"
enableIsDeviceOn=false
apkD=$1

echo "Running Multiple Device Installer version $version, by Ramon Valk."
    
    #checking for correct use
    if [ -z "$1" ]; then
        echo "ERROR: No apk argument given, try using 'mdInstaller [apk name]'"
        exit 2
    fi


    #set permissions
    chmod 755 "$0"

    #checking if apk exists
    if [ -f "$apkD" ]
      then
          echo "Application $apkD found."
      else
          echo "ERROR: Application $apkD not found, exiting..."
          exit 3
    fi


   
     #searching for devices 
     echo "\nChecking for attached devices..."
     inputDevicesString=$(./data/adb devices | grep -v List | grep device | perl -p -e 's/(\w+)\s.*/\1/')
     inputDevicesArray=(`echo ${inputDevicesString}`);
     deviceNMR=$(echo ${#inputDevicesArray[@]})
     echo "\nFound $deviceNMR device(s)!"
     if [[ "$deviceNMR" -eq 0 ]]; then
         echo "ERROR: No devices found, exiting..."
         exit 3
     fi


     #gettting model number via getprop
     echo "Device name(s) : "
     for (( i = 0; i < $deviceNMR; i++ )); do
        ./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model
         
     done

    #get package name via aapt
    aaptDump=$(./data/aapt dump badging "$apkD" | grep package:\ name)
    echo "Getting package name from apk..."
    packageName=$(echo $aaptDump| cut -d"'" -f 2)

    echo "\nPackage name found : $packageName\n"

    #install apk via adb
    echo "Installing apk...\n"
    for (( i = 0; i < $deviceNMR; i++ )); do
        ./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model
        ./data/adb -s ${inputDevicesArray[$i]} install "$apkD"
        echo "\n" 
    done

    #launch app via monkey
    echo "\nOpening $packageName\n"
    for (( i = 0; i < $deviceNMR; i++ )); do
        if [[ "$enableIsDeviceOn" == true ]]; then
            sh isDeviceOn.sh ${inputDevicesArray[$i]} 
        fi
        ./data/adb -s ${inputDevicesArray[$i]} shell monkey -p "$packageName" -c android.intent.category.LAUNCHER 1
    done
    echo "\nWe are done here. 👋🏼  \n"
    sleep 0.2
exit 0