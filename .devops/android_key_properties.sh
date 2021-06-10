#!/bin/bash
sed -e "s|{{password}}|$1|g" android/key.properties.template  | tee android/key.properties
cat android/key.properties

sed -e "s|{{path}}|$2|g" android/key.properties | tee android/key.properties
cat android/key.properties
