#!/bin/bash
rm -f android/key.properties.template
echo storePassword=$1 >> android/key.properties.template
echo keyPassword=$1 >> android/key.properties.template
echo keyAlias=upload >> android/key.properties.template
echo storeFile=$2 >> android/key.properties.template

cat android/key.properties
