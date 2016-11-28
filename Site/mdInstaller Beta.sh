#!/bin/bash
# Multiple Device Installer - Ramon Valk
version="1.2"
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

        dModel=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model)
        dModel=$(echo "${dModel//[$'\t\r\n ']}")
        dRelease=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.release)
        dRelease=$(echo "${dRelease//[$'\t\r\n ']}")
        dApi=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.sdk)
        dApi=$(echo "${dApi//[$'\t\r\n ']}")
        dSPatch=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.security_patch)
        dSPatch=$(echo "${dSPatch//[$'\t\r\n ']}")
        dSerial=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.boot.serialno)
        dSerial=$(echo "${dSerial//[$'\t\r\n ']}")
        echo "📱 $dModel ➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖"
        echo "Connected with Android version $dRelease, Api level $dApi,\nSecurity Patch $dSPatch and Serial $dSerial"
        echo "📱 $dModel ➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖"
        echo "\n" 
     done

    #get package name via aapt
    aaptDump=$(./data/aapt dump badging "$apkD" | grep package:\ name)
    echo "\nGetting package info from apk..."
    packageName=$(echo $aaptDump| cut -d"'" -f 2)
    echo "Package name found : $packageName"
    sdkVersion=$(./data/aapt dump badging "$apkD" | grep sdkVersion | tr -d 'sdkVersion:' | tr -d "'")
    echo "API Level found: $sdkVersion"

    #install apk via adb
    echo "Checking installation requirements...\n"
    for (( i = 0; i < $deviceNMR; i++ )); do
    	apiApp=$(./data/aapt dump badging "$apkD" | grep sdkVersion | tr -d 'sdkVersion:' | tr -d "'")
    	apiApp=$(echo "${apiApp//[$'\t\r\n ']}")
    	apiDevice=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.sdk)
    	apiDevice=$(echo "${apiDevice//[$'\t\r\n ']}")
  		dModel=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model)
  		dModel=$(echo "${dModel//[$'\t\r\n ']}")
  		echo "📱 $dModel"
    	if [[ "$apiApp" -le "$apiDevice" ]] 
    		then
    			echo "API Level seems lower or equal."
    			package=$(adb -s ${inputDevicesArray[$i]} shell pm list packages $packageName)
    			packageCut=$(echo "$package" | grep $packageName | cut -c 9-)
    			packageCheck=$(echo "${packageCut//[$'\t\r\n ']}")
    			if [[ "$packageCheck" == "$packageName" ]]; then
    				echo "Application already installed, trying to uninstall..."
    				./data/adb -s ${inputDevicesArray[$i]} uninstall "$packageName"
    			fi
    			echo "Installing..."
       		    ./data/adb -s ${inputDevicesArray[$i]} install "$apkD"
       	elif [[ "$apiApp" -gt "$apiDevice" ]] 
       		then
       		    echo "API Level from App seems higher, skipping installation."
       	else	
       			echo "ERROR: Something went wrong while checking API Level before installation." 
       			exit 4   	
    	fi
        echo "\n" 
    done

    #launch app via monkey
    echo "\nOpening $packageName\n"
    for (( i = 0; i < $deviceNMR; i++ )); do

    	apiApp=$(./data/aapt dump badging "$apkD" | grep sdkVersion | tr -d 'sdkVersion:' | tr -d "'")
    	apiApp=$(echo "${apiApp//[$'\t\r\n ']}")
    	apiDevice=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.sdk)
    	apiDevice=$(echo "${apiDevice//[$'\t\r\n ']}")
  		dModel=$(./data/adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model)
  		dModel=$(echo "${dModel//[$'\t\r\n ']}")
  		echo "📱 $dModel"
    	if [[ "$apiApp" -le "$apiDevice" ]] 
    		then
    			echo "API Level seems lower or equal, opening..."
       		    if [[ "$enableIsDeviceOn" == true ]]; then
            sh isDeviceOn.sh ${inputDevicesArray[$i]} 
        fi
        ./data/adb -s ${inputDevicesArray[$i]} shell monkey -p "$packageName" -c android.intent.category.LAUNCHER 1
       	elif [[ "$apiApp" -gt "$apiDevice" ]] 
       		then
       		    echo "API Level from App seems higher, skipping command."
       	else	
       			echo "ERRROR: Something went wrong while checking API Level before opening." 
       			exit 5   	
    	fi
    done
    echo "\nWe are done here. 👋🏼  \n"
    sleep 0.2
exit 0