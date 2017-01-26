#!/bin/sh
# Multiple Device Installer - Ramon Valk
version="1.2"
enableIsDeviceOn=false
usingSelectFlag=false
usingNonAPKFlag=false
inputDevicesArray=
deviceNMR=
apkD=
min=
Max=

search () {
     #searching for devices 
     echo "Checking for attached devices..."
     inputDevicesString=$(adb devices | grep -v List | grep device | perl -p -e 's/(\w+)\s.*/\1/')
     inputDevicesArray=(`echo ${inputDevicesString}`);
     deviceNMR=$(echo ${#inputDevicesArray[@]})
     echo "Found $deviceNMR device(s)!"
     if [[ "$deviceNMR" -eq 0 ]]; then
         echo "ERROR: No devices found, exiting..."
         exit 3
     fi

     #gettting model number via getprop
     echo "Device name(s) : "
     for (( i = 0; i < $deviceNMR; i++ )); do

        dModel=$(adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model)
        dModel=$(echo "${dModel//[$'\t\r\n ']}")
        dRelease=$(adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.release)
        dRelease=$(echo "${dRelease//[$'\t\r\n ']}")
        dApi=$(adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.sdk)
        dApi=$(echo "${dApi//[$'\t\r\n ']}")
        dSPatch=$(adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.security_patch)
        dSPatch=$(echo "${dSPatch//[$'\t\r\n ']}")
        dSerial=$(adb -s ${inputDevicesArray[$i]} shell getprop ro.boot.serialno)
        dSerial=$(echo "${dSerial//[$'\t\r\n ']}")
        echo "📱 $dModel ➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖"
        echo "Connected with Android version $dRelease, Api level $dApi,\nSecurity Patch $dSPatch and Serial $dSerial"
        echo "📱 $dModel ➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖"
        echo "\n" 
     done
}

inputDevices () {
	search
	#checking if apk exists
	if [[ "$usingNonAPKFlag" = false ]]; then
	    if [ -f "$apkD" ]
	      then
	          echo "Application $apkD found.\n"
	      else
	          echo "ERROR: Application $apkD not found,try using 'mdInstaller -a [argument]'"
	          exit 3
	    fi
	fi
	#setting devices to install on
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
	echo $sOutput
	toArray=$(echo "$sOutput")
	IFS=' ' read -r -a array <<< "$toArray"
	inputDevicesArray=$array
	deviceNMR=(${#array[@]})
}

killAllDevices () {
	if [[ "$usingSelectFlag" = false ]]; then
    	search
    fi
	echo "Killing all (selected) devices..."
	echo "Hint: using -s before -k gives you the option to shutdown a selection of devices."
	for (( i = 0; i < $deviceNMR; i++ )); do
       adb -s ${inputDevicesArray[$i]} shell reboot -p
    done
    echo "\nWe are done here. 👋🏼  \n"
}

lockAllDevices () {
	if [[ "$usingSelectFlag" = false ]]; then
    	search
    fi
	echo "Simulating pressing off powerbutton."
	for (( i = 0; i < $deviceNMR; i++ )); do
       adb -s ${inputDevicesArray[$i]} shell input keyevent 26
    done
    echo "\nWe are done here. 👋🏼  \n"
}

powerAllDevices () {
	if [[ "$usingSelectFlag" = false ]]; then
    	search
    fi
	echo "(Re)booting all (selected) devices..."
	echo "Not all devices support cold booting!"
	echo "Hint: using -s before -r gives you the option to power on a selection of devices."
	for (( i = 0; i < $deviceNMR; i++ )); do
       adb -s ${inputDevicesArray[$i]} shell reboot
    done
}

getPackageName () {
    aaptDump=$(aapt dump badging "$apkD" | grep package:\ name)
    echo "\nGetting package info from apk..."
    packageName=$(echo $aaptDump| cut -d"'" -f 2)
    echo "Package name found : $packageName"
    sdkVersion=$(aapt dump badging "$apkD" | grep sdkVersion | tr -d 'sdkVersion:' | tr -d "'")
    echo "API Level found: $sdkVersion"
}

getPackageInfo () {
	package=$(adb -s ${inputDevicesArray[$i]} shell pm list packages $packageName)
	packageCut=$(echo "$package" | grep $packageName | cut -c 9-)
	packageCheck=$(echo "${packageCut//[$'\t\r\n ']}")
}

getApiInfo () {
	apiApp=$(aapt dump badging "$apkD" | grep sdkVersion | tr -d 'sdkVersion:' | tr -d "'")
	apiApp=$(echo "${apiApp//[$'\t\r\n ']}")
	apiDevice=$(adb -s ${inputDevicesArray[$i]} shell getprop ro.build.version.sdk)
	apiDevice=$(echo "${apiDevice//[$'\t\r\n ']}")
	dModel=$(adb -s ${inputDevicesArray[$i]} shell getprop ro.product.model)
	dModel=$(echo "${dModel//[$'\t\r\n ']}")
}

openApp () {
	search
	#get package name via aapt
	getPackageName
	    for (( i = 0; i < $deviceNMR; i++ )); do

	    	getApiInfo
	  		echo "📱 $dModel"
	    	if [[ "$apiApp" -le "$apiDevice" ]] 
	    		then
	    			echo "API Level seems lower or equal, opening..."
	       		    if [[ "$enableIsDeviceOn" == true ]]; then
	            sh isDeviceOn.sh ${inputDevicesArray[$i]} 
	        fi
	        adb -s ${inputDevicesArray[$i]} shell monkey -p "$packageName" -c android.intent.category.LAUNCHER 1
	       	elif [[ "$apiApp" -gt "$apiDevice" ]] 
	       		then
	       		    echo "API Level from App seems higher, skipping command."
	       	else	
	       			echo "ERRROR: Something went wrong while checking API Level before opening."
	       			exit 5   	
	    	fi
	    done
}

echo "\nRunning Multiple Device Installer version $version, by Ramon Valk."
    #Flag systeem, "x:" is een flag met parameter, "x" zonder.
	while getopts "m:M:a:A:o:S:hdskrl" opt; do
	  case $opt in
	  	h)
		  echo "\nUsage: mdInstaller -a [apk]" >&2
		  echo "Options:"
		  echo "-a : Application, this flag is non optional in some cases, has to be used first and must point to a apk file."
		  echo "-d : Check for connected devices."
		  echo "-h : Show all options."
		  echo "-s : Set the devices to be installed on, this will start a selection menu."
		  echo "-S : Serial, using this flag you can input a serial just like the adb command, example: '-S o420974bc133788d'."
		  echo "-m : Minimum API level, example: '-m 17'."
		  echo "-M : Maximum API level, example: '-M 23'."
		  echo "-o : Open application on device, needs a apk file to get package name, example: '-o bite.apk'."
		  echo "-k : Turn off all devices, can be useful for charging tablets overnight."
		  echo "-l : Simulate pressing of the power button, can lock or unlock devices."
		  echo "-r : Reboot / Turn on devices that support cold boot.\n"
		  exit 1
		  ;;
	    m)
	      echo "Minimum (-m) was triggered: $OPTARG" >&2
	      min=$OPTARG
	      ;;
	    M)
		  echo "Maximum (-M) was triggered: $OPTARG" >&2
		  Max=$OPTARG
		  ;;
		a)
		   apkD=$OPTARG >&2
		   ;;
		A)
		   apkD=$OPTARG >&2
		   ;;
		d)
		   usingNonAPKFlag=true
		   search >&2
		   exit 1
		   ;;
		s)
		   usingSelectFlag=true >&2
		   usingNonAPKFlag=true
		   inputDevices 
		   ;;
		S) usingSelectFlag=true >&2
		   inputDevicesArray[0]="$OPTARG"
		   deviceNMR=1
		   ;;
		k)
		   usingNonAPKFlag=true >&2
		   killAllDevices
		   exit 1
		   ;;
		l) 
		   usingNonAPKFlag=true >&2
		   lockAllDevices
		   exit 1
		   ;;
		r)
		   usingNonAPKFlag=true >&2
		   powerAllDevices
		   exit 1
		   ;;
		o)
		   usingNonAPKFlag=true >&2
		   apkD=$OPTARG >&2
		   openApp
		   exit 0
		   ;;
	    \?)
	      echo "Invalid option: -$OPTARG" >&2
	      exit 1
	      ;;
	    :)
	      echo "Option -$OPTARG requires an argument." >&2
	      exit 1
	      ;;
	  esac
	done

	  #checking for correct use
    if [[ "$usingNonAPKFlag" = false ]]; then
	    if [[ -z "apkD" ]]; then
	        echo "ERROR: No apk argument given, try using 'mdInstaller -a [argument]'"
	        exit 2
	    fi
	fi
    #set permissions
    chmod 755 "$0"

    #checking if apk exists
    if [[ "$usingNonAPKFlag" = false ]]; then
	    if [ -f "$apkD" ]
	      then
	          echo "Application $apkD found.\n"
	      else
	          echo "ERROR: Application $apkD not found,try using 'mdInstaller -a [argument]'"
	          exit 3
	    fi
	fi

    if [[ "$usingSelectFlag" = false ]]; then
    	search
    fi

    #get package name via aapt
    getPackageName
    echo "Checking installation requirements...\n"

    if [[ -z "$min" ]] && [[ -z "$Max" ]]; then
    	#install apk via adb
	   for (( i = 0; i < $deviceNMR; i++ )); do
	    	getApiInfo
	  		echo "📱 $dModel"
		    	if [[ "$apiApp" -le "$apiDevice" ]] 
		    		then
		    			echo "API Level seems lower or equal."
		    			getPackageInfo
		    			if [[ "$packageCheck" == "$packageName" ]]; then
		    				echo "Application already installed, trying to uninstall..."
		    				adb -s ${inputDevicesArray[$i]} uninstall "$packageName"
		    			fi
		    			echo "Installing..."
		       		    adb -s ${inputDevicesArray[$i]} install "$apkD"
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
	    	getApiInfo
	  		echo "📱 $dModel"
	    	if [[ "$apiApp" -le "$apiDevice" ]] 
	    		then
	    			echo "API Level seems lower or equal, opening..."
	       		    if [[ "$enableIsDeviceOn" == true ]]; then
	            sh isDeviceOn.sh ${inputDevicesArray[$i]} 
	        fi
	        adb -s ${inputDevicesArray[$i]} shell monkey -p "$packageName" -c android.intent.category.LAUNCHER 1
	       	elif [[ "$apiApp" -gt "$apiDevice" ]] 
	       		then
	       		    echo "API Level from App seems higher, skipping command."
	       	else	
	       			echo "ERRROR: Something went wrong while checking API Level before opening." 
	       			exit 5   	
	    	fi
	    done
	
    elif [[ -n "$min" ]] && [[ -z "$Max" ]]; then
  				echo "Min is set, this can have a big impact on installation."
  		for (( i = 0; i < $deviceNMR; i++ )); do
  			getApiInfo
	  		echo "📱 $dModel"
		    	if [[ "$min" -le "$apiDevice" ]] 
		    		then
		    			echo "API Level seems lower or equal."
		    			getPackageInfo
		    			if [[ "$packageCheck" == "$packageName" ]]; then
		    				echo "Application already installed, trying to uninstall..."
		    				adb -s ${inputDevicesArray[$i]} uninstall "$packageName"
		    			fi
		    			echo "Installing..."
		       		    adb -s ${inputDevicesArray[$i]} install "$apkD"
		       	elif [[ "$min" -gt "$apiDevice" ]] 
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
	    	getApiInfo
	  		echo "📱 $dModel"
	    	if [[ "$apiApp" -le "$apiDevice" ]] 
	    		then
	    			echo "API Level seems lower or equal, opening..."
	       		    if [[ "$enableIsDeviceOn" == true ]]; then
	            sh isDeviceOn.sh ${inputDevicesArray[$i]} 
	        fi
	        adb -s ${inputDevicesArray[$i]} shell monkey -p "$packageName" -c android.intent.category.LAUNCHER 1
	       	elif [[ "$apiApp" -gt "$apiDevice" ]] 
	       		then
	       		    echo "API Level from App seems higher, skipping command."
	       	else	
	       			echo "ERRROR: Something went wrong while checking API Level before opening."
	       			exit 5   	
	    	fi
	    done

    elif [[ -n "$Max" ]] && [[ -z "$min" ]]; then
  					echo "Max is set, this can have a big impact on installation."
  		for (( i = 0; i < $deviceNMR; i++ )); do
  			getApiInfo
	  		echo "📱 $dModel"
		    	if [[ "$apiDevice" -le "$Max" ]] 
		    		then
		    			echo "API Level seems lower or equal."
		    			getPackageInfo
		    			if [[ "$packageCheck" == "$packageName" ]]; then
		    				echo "Application already installed, trying to uninstall..."
		    				adb -s ${inputDevicesArray[$i]} uninstall "$packageName"
		    			fi
		    			echo "Installing..."
		       		    adb -s ${inputDevicesArray[$i]} install "$apkD"
		       	elif [[ "$apiDevice" -gt "$Max" ]] 
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
	    	getApiInfo
	  		echo "📱 $dModel"
	    	if [[ "$apiDevice" -le "$Max" ]] 
	    		then
	    			echo "API Level seems lower or equal, opening..."
	       		    if [[ "$enableIsDeviceOn" == true ]]; then
	            sh isDeviceOn.sh ${inputDevicesArray[$i]} 
	        fi
	        adb -s ${inputDevicesArray[$i]} shell monkey -p "$packageName" -c android.intent.category.LAUNCHER 1
	       	elif [[ "$apiDevice" -gt "$Max" ]] 
	       		then
	       		    echo "API Level from App seems higher, skipping command."
	       	else	
	       			echo "ERRROR: Something went wrong while checking API Level before opening."
	       			exit 5   	
	    	fi
	    done
  	elif [[ "$min" -le "$apiDevice" ]] && [[ "$apiDevice" -le "$Max" ]]; then
  		echo "Max and min are set, this can have a big impact on installation."


  	else
  		echo "ERROR: Something went wrong while setting min (-m) or max (-M) flags."
  		exit 6
  	fi

    
    echo "\nWe are done here. 👋🏼  \n"
    sleep 0.2
exit 0