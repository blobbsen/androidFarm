#/bin/bash
checkDat () {
	if [ $1 -gt 0 ]; then
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

# checking length of args
if [ $# -lt 6 ]; then
	echo "to less arguments... : /"
	exit 1
fi
# turning display on
adb -s $2 shell input keyevent 26

echo ""
echo ""
echo "----- may uninstalling previous version of apks -----"
adb -s $2 uninstall $5
adb -s $2 uninstall $6
echo ""
echo "----- installing apks -----"
adb -s $2 install $1/$3
adb -s $2 install $1/$4
echo ""
echo "----- run tests -----"
adb -s $2 shell am instrument -w -e reportDir /storage/sdcard0/androidFarm $6/com.zutubi.android.junitreport.JUnitReportTestRunner
#checkDat $?

echo ""
echo "----- pull report -----"
adb -s $2 pull /storage/sdcard0/androidFarm/junit-report.xml
#checkDat $?
echo ""
echo "----- uninstalling apks & removing remote report -----"
adb -s $2 shell rm /storage/sdcard0/androidFarm/*
#checkDat $?
adb -s $2 uninstall $5
checkDat $?
adb -s $2 uninstall $6
checkDat $?
# turning display off
adb -s $2 shell input keyevent 26
echo ""
echo ""
