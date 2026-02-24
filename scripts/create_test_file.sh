#!/bin/sh
# Creates a file on /sdcard so you can verify it exists
echo "Patch ran successfully at $(date)" > /sdcard/patch_test.txt
echo "File created: /sdcard/patch_test.txt"
cat /sdcard/patch_test.txt
