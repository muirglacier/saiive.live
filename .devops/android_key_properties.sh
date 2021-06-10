#!/bin/bash
echo $(android-upload-key-base64) | base64 --decode > upload-key.jks
echo $(android-key-properties) | base64 --decode > android/key.properties

cat android/key.properties

sed 's|{{source_dir}}|$(Build.SourcesDirectory)|g' android/key.properties > android/key.properties
cat android/key.properties