#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

echo "STEPS TO MANUALLY TEST ASSIGNMENT 8"

echo "After following steps 3 and 4"
echo "CD INTO YOUR aesd-char-driver DIRECTORY"
echo "do a `make`"
echo "From you main root assignment directory,"
echo "RUN ./assignment-autotest/test/assignment8/drivertest.sh to verify you implementation"

echo "After following step 5"
echo "From you main root assignment directory,"
echo "RUN your aesdsocket"
echo "And verify with it runs against sockettest.sh by running"
echo "./assignment-autotest/test/assignment8/sockettest.sh"