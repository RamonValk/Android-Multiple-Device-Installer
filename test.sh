#!/bin/bash
# Test script - Ramon Valk

# read data ramon
#adbD /Users/RamonValk/android
#aapt 

echo "Hey whatsup, You're running $0, are you sure you want to proceed?"

read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    chmod 755 $0

    function setData {
     echo "We are going to need a bit of information from you: \n"
     read -p "The path to the APK file you want to install : " apkD
     read -p "Your admin password, (only needed for sudo commands) : " passD
     inputDevices=$(./data/adb devices)
     for (( i = 0; i < 2; i++ )); do
        lineCounter=5
         inputDevicesCut[$i]=$(echo $inputDevices | cut -d" " -f $lineCounter)
         lineCounter=$lineCounter+2
     echo "$inputDevicesCut[$i]"
     done
     #inputDevicesCut=$(echo $inputDevices | cut -d" " -f 5)
     #echo "$inputDevicesCut"
  

     echo "\n Okey, you entered $apkD as your path. Is this correct?"
     read -r -p "[y/N]" dataResponse
    if [[ $dataResponse =~ ^[nN]$ ]]; then
        setData
    fi
    echo "\nOkey, let's proceed.\n"
     }

    setData

    sleep 2
    aaptDump=$(./data/aapt dump badging $apkD | grep package:\ name)
    echo "Getting package name from apk..."
    packageName=$(echo $aaptDump| cut -d"'" -f 2)
    sleep 1.5
    echo "\nPackage name found : $packageName\n"
    echo "Installing apk...\n"
    ./data/adb install $apkD
    sleep 1
    echo "\nOpening $packageName\n"
    ./data/adb shell monkey -p $packageName -c android.intent.category.LAUNCHER 1
    sleep 2
    echo "\nWe are done here. 👋🏼  \n"

    
    




else
    echo "\nWell bye 👋🏼  \n"
    sleep 2.5
    exit
fi


#./data/aapt dump badging $apkD | grep package:\ name
#./aapt dump badging app.apk | grep package:\ name
#./adb shell monkey -p your.app.package.name -c android.intent.category.LAUNCHER 1