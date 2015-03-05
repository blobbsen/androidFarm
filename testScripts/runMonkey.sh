#/bin/bash
checkDat () {
	if [ $1 -gt 0 ]; then
		# turning display off
		adb -s $2 shell input keyevent 26
 		exit 1
	fi
}

### args ###
# $1 = workspace
# $2 = serial
# $3 = apk
# $4 = package
# $5 = amount events
# $6 = delay beetween events in ms
# $7 = seed

echo "--- run monkey ---"
# checking length of args
if [  -lt 5 ]; then
	echo "to less arguments... : /"
fi
# turning display on
adb -s $2 shell input keyevent 26

echo "installing apks"
cd $1
adb -s $2 install $3
checkDat $?

echo "run tests"
if [ $# ==  5 ]
then
	adb -s $2 shell monkey -p $4 -v $5 > monkey.txt
	checkDat $?
elif [ $# == 6 ]
then
        adb -s $2 shell monkey -p $4 -v $5 --throttle $6 > monkey.txt
        checkDat $?
elif [ $# == 7 ]
then
        adb -s $2 shell monkey -p $4 -v $5 --throttle $6 -s $7 > monkey.txt
        checkDat $?
fi

echo "clean up"
adb -s $2 uninstall $4
checkDat $?
# turning display off
adb -s $2 shell input keyevent 26
