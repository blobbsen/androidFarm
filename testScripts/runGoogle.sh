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
# $4 = test apk
# $5 = package
# $6 = test package

echo "--- run Tests with Google runner ---"
# checking length of args
if [ $# -lt 6 ]; then
	echo "to less arguments... : /"
	exit 1
fi
# turning display on
adb -s $2 shell input keyevent 26

echo "installing apks"
cd $1
adb -s $2 install $3
checkDat $?
adb -s $2 install $4
checkDat $?

echo "run tests"
adb -s $2 shell am instrument -w $6/com.google.android.apps.common.testing.testrunner.GoogleInstrumentationTestRunner > google-report.xml
checkDat $?

echo "clean up"
adb -s $2 uninstall $5
checkDat $?
adb -s $2 uninstall $6
checkDat $?
#turning display off
adb -s $2 shell input keyevent 26
