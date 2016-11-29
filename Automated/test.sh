#!/bin/bash
testvar=$(adb shell pm list packages)
echo $testvar