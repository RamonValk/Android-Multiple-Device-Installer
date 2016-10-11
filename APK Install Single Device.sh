#!/bin/bash
# Single Device APK Installer - Ramon Valk

echo "Hey whatsup, You're running $0, are you sure you want to proceed?"

read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	#set permissions
    chmod 755 "$0"
    #data function for reentering apk info
    function setData {
     echo "We are going to need a bit of information from you: \n"
     read -p "The path to the APK file you want to install : " apkD
     echo "\n Okey, you entered $apkD as your path. Is this correct?"
     read -r -p "[y/N]" dataResponse
    if [[ $dataResponse =~ ^[nN]$ ]]; then
        setData
    fi
    echo "\nOkey, let's proceed.\n"
     }

    setData
    sleep 2
    #get package name from aapt
    aaptDump=$(./data/aapt dump badging $apkD | grep package:\ name)
    echo "Getting package name from apk..."
    packageName=$(echo $aaptDump| cut -d"'" -f 2)
    sleep 1.5
    echo "\nPackage name found : $packageName\n"
    #installing apk via adb
    echo "Installing apk...\n"
    ./data/adb install $apkD
    sleep 1
    #launch app via monkey
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