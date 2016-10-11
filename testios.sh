#!/bin/bash

xcodebuild test \
    -project Operacjas.xcodeproj \
    -scheme "Operacjas iOS" \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 6s,OS=10.0' \
    | xcpretty && exit ${PIPESTATUS[0]}
