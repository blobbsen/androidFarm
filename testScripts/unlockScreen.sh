#!/bin/bash

# lock screen
adb -s $1 shell input keyevent 27
# unlock screen
adb -s $1 shell input keyevent 26
# delay for nexus 7 lollipop, otherwise fails
sleep 2
# call view to enter pin
#adb shell input keyevent 66 doesn't work with  nexus 7 on lollipo
adb -s $1 shell monkey -v 10
sleep 1
#enter in case we typed some digits
adb -s $1 shell input keyevent 66

# pin code (keyevent = digit + 7)
adb -s $1 shell input keyevent 8
adb -s $1 shell input keyevent 10
adb -s $1 shell input keyevent 10
adb -s $1 shell input keyevent 15

# enter
adb -s $1 shell input keyevent 66
# there you go
