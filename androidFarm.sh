#!/bin/bash

# custom variables, must change
jenkinsMaster="http://192.168.1.101:8080"
base=`echo pwd`

# specify credentials with administer and generic read permission,
# in order to read the status of jenkins slave instances
user=""
password=""

# arrays for processing
name=()
secret=()
serial=()

# counter for while loop
counter=0

#### functions ####
getData() {

	# reset
	counter=0

	while read line; do

		name[$counter]=`echo $line | awk '{split($0,a," "); print a[1]}'`
		secret[$counter]=`echo $line | awk '{split($0,a," "); print a[2]}'`
		serial[$counter]=`echo $line | awk '{split($0,a," "); print a[3]}'`
		pid[$counter]=`echo $line | awk '{split($0,a," "); print a[4]}'`
		((counter++))

	done <  ${base}/devices.conf
}

evaluate () {
	((counter--))

	for ((i=0;i<=${counter};i++)); do

		# checking status
		deviceIsConnected=$(isConnected ${serial[$i]})

		if [ "$deviceIsConnected" == "true" ]; then

			# check if slave needs to be started			
			OUTPUT=`ls ${base}/temp/ | grep ${name[i]}`
			if [ ${#OUTPUT} -lt 1 ]; then

				echo ""
				echo ""
				echo ""
				echo "############ `date` ############"
				echo ""
				echo "device for slave: ${name[i]} connected, starting its slave instance..."
				echo ""
				echo "---------- log of 'java -jar slave.jar' --------------------------"
				startSlave $i
				echo ""
				
				#echo "---------- checking status of slave --------------------"				

				#slaveStatus=$(getStatus ${name[$i]})
				#echo "--------------------------------------------------------------------"
				#echo ""

				#if [ "$slaveStatus" == "offline" ]; then
				#	echo "starting slave instance for ${name[i]} failed !!!" 
				#else
				#	echo "starting slave instance for ${name[i]} successful"
				#fi
			fi
		else
			# check if shut down for slave is necessary
			OUTPUT=`ls ${base}/temp/ | grep ${name[i]}`
			if [ ${#OUTPUT} -gt 0 ]; then

				echo ""
				echo ""
				echo ""
				echo "############ `date` ############"
				echo ""
				echo "device for slave: ${name[i]} disconnected, killing its slave instance..."
				echo ""

				# cutting pid from folder name (chars after last occurence of "_")
				pid=${OUTPUT##*_}

				kill $pid >> ${base}/temp/garbage
				
				echo ""
				#sleep 10
				#echo "---------- checking status of slave --------------------"
				#slaveStatus=$(getStatus ${name[$1]})
				
				#echo "--------------------------------------------------------------------"
				#echo ""
				#if [ "$slaveStatus" == "offline" ]; then
					echo "killing slave instance for ${name[i]} successful"
					rmdir ${base}/temp/${OUTPUT}
				#else
				#	echo "killing slave instance for ${name[i]} failed !!!"
				#fi
				echo ""
			fi
		fi
	done
}

## slave specific functions
startSlave () {

	# TO DO: implement startSlave.sh script inside this one
	pidTemp=$( bash ${base}/startSlave.sh ${jenkinsMaster} ${name[$1]} ${secret[$1]} ${base} )
	sleep 30

	echo "$(cat ${base}/temp/workAround.txt)"
	echo "--------------------------------------------------------------------"

	# deleting workAround.txt for next loop
	rm ${base}/temp/workAround.txt

	# ganz anders und dann wieder mit ordnern
	# creating instance blakeks
	mkdir ${base}/temp/${name[$1]}_${pidTemp}
}

getStatus () {

	cd ${base}/temp
	# so jenkins got some time to refresh its content!!!! must be there
	sleep 20

	if [ "$user" == "" ]; then
		wget --no-check-certificate ${jenkinsMaster}/computer/
	else
		wget --no-check-certificate --auth-no-challenge --http-user=${user} --http-password=${password} ${jenkinsMaster}/computer/
	fi

	webpage=`cat ${base}/temp/index.html`
	rm ${base}/temp/index.html

	cd ${base}

	if [[ $webpage == *"${name[$1]}</a>  (offline)<"* ]]; then
  		echo "offline";
	else
 		echo "online";
	fi
}

## adb specific function
isConnected () {

	OUTPUT=`adb devices | grep $1`
	if [ ${#OUTPUT} -lt 1 ]; then
        	echo "false"
    	else
        	echo "true"
	fi
}

######################## script ##########################

# command specific processes #
if [ "$1" == "start" ]; then

	if [ "$2" != "notInitial" ]; then
		echo ""
		echo "-------------- starting androidFarm daemon ---------------"

		# check if setup is needed
		mkdir -p ${base}/master
		mkdir -p ${base}/slaves
		mkdir -p ${base}/temp

		# deleting temporary files
		rm -rf ${base}/temp/*
	fi

	getData
	evaluate

	# delay
	sleep 10
	bash ${base}/androidFarm.sh start notInitial
fi

if [ "$1" == "add" ]; then

	echo ""
	echo "---------------------- androidFarm -----------------------"
	echo ""
	echo "adding androidSlave $2 with serial $4"

	# TO DO: create slave directory and softlinking tools dir of androidFarm master
	mkdir ${base}/slaves/$2
	ln -s ${base}/master/tools ${base}/slaves/$2/tools

	newDevice="$2 $3 $4"

	# add it to the devices.conf
	echo $newDevice >> ${base}/devices.conf
	echo ""
	echo "----------------------------------------------------------"
	echo ""
fi

if [ "$1" == "list" ]; then

	# TO DO: list of new devices. einfach drei arrays machen und fertig.
	# der eine wird gegen das andere gepushed. 
	echo ""
	echo "---------------------- androidFarm -----------------------"
	echo ""
	echo "--- list of connected devices ---"
	
	echo `adb devices`
	#	just works with nexus devices
	#
	# to do: try to save in variable and echo instead of cat
	#
	#adb devices -l > ${base}/temp/adbList
	#ARRAY=( $(cat ${base}/temp/adbList | tr '\n' ' ') )
	#rm ${base}/temp/adbList

	#for (( i=4; i<${#ARRAY[@]}; i++ )); do

   	#	temp="${ARRAY[$(($i+4))]}"

	#	if [ "$temp" == "" ]; then
	#		temp="unauthorised device"
	#	fi

	#	echo "${temp} serial: ${ARRAY[$i]}"

  	#	i=$(($i+5))

	#done


	echo ""
	echo "--- list of known devices ---"

	knownDevices=( $(cat ${base}/devices.conf | tr '\n' ' ') )
	for (( i=0; i<${#knownDevices[@]}; i++ )); do

  		temp2=$(($i+2))

  		echo "name: ${knownDevices[i]} serial: ${knownDevices[$temp2]}"

  		i=$(($i+2))
	done

	echo ""
	echo "----------------------------------------------------------"
	echo ""
fi
