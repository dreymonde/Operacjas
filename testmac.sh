#!/bin/bash

xcodebuild test \
    -project Operacjas.xcodeproj \
    -scheme "Operacjas Mac" \
    -destination "platform=OS X,arch=x86_64" \
    | xcpretty && exit ${PIPESTATUS[0]}


