#!/bin/bash
# customize with your own.

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



#options=("AAA" "BBB" "CCC" "DDD")
 options=("${inputDevicesArray[@]}")

menu() {
    echo "Avaliable options:"
    for i in ${!options[@]}; do 
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#options[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done

printf "You selected "; msg=" nothing"
sOutput=$(for i in ${!options[@]}; do 
    [[ "${choices[i]}" ]] && { printf " %s" "${options[i]}"; msg=""; }
done)
sList=' ' read -r -a array <<< "$sOutput"
echo $sOutput
echo "okey dan\n"
echo "${sList[0]}"