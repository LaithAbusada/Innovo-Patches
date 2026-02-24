#!/bin/sh
# Sets a custom system property — verify with: adb shell getprop innovo.patch.test
setprop innovo.patch.test "applied_$(date +%Y%m%d_%H%M%S)"
echo "Property set: innovo.patch.test = $(getprop innovo.patch.test)"
