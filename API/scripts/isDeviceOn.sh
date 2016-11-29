#!/bin/bash
# isDeviceOn script - Ramon Valk

version="0.4"
serial=$1
pinMode=true
pinCode="7783" #this code is used on all connected devices. So use the same pin or remove it completely. 

echo "running isDeviceOn version $version."
#checking for correct use
    if [ -z "$1" ]; then
        echo "ERROR: No serial argument given, try using 'isDeviceOn [serial]'"
        exit 2
    fi

echo "serial is : $serial"
if [[ "$pinMode" == false ]]; then
	echo "PIN Mode set to false, phones with PIN won't work."
else
	echo "PIN Mode set to true, code : $pinCode, phones without PIN might act weird."
fi

screen_info=`adb -s $serial shell dumpsys input_method | grep mInteractive=true`
if [[ $screen_info == *"mInteractive"* ]]
then
    echo "Screen is ON, checking if locked..."
    screenLocked=$(./data/adb -s $serial shell dumpsys input_method | grep -i mActive)
    if [[ $screenLocked == *"mHasBeenInactive=true"* ]]
    	then	
    		 echo "Locked, unlocking..."
    		 if [[ "$pinMode" == false ]]
    			then
   	   	 		   ./data/adb -s $serial shell input keyevent 82
   				else
					./data/adb -s $serial shell input keyevent 82
					./data/adb -s $serial shell input text $pinCode
					./data/adb -s $serial shell input keyevent 66
    		 fi
    	else
    		 echo "Not locked, skipping..."
    	

    fi

else
    echo "Screen is OFF, powering on and unlocking..."
    if [[ "$pinMode" == false ]]
    	then
    		./data/adb -s $serial shell input keyevent 26
   	   	    ./data/adb -s $serial shell input keyevent 82
   		else
   			./data/adb -s $serial shell input keyevent 26
			./data/adb -s $serial shell input keyevent 82
			./data/adb -s $serial shell input text $pinCode
			./data/adb -s $serial shell input keyevent 66
    fi
fi