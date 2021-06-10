#!/bin/bash
rm -f android/key.properties
echo storePassword=$1 >> android/key.properties
echo keyPassword=$1 >> android/key.properties
echo keyAlias=upload >> android/key.properties
echo storeFile=$2 >> android/key.properties

cat android/key.properties
