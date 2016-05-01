#!/bin/bash

xcodebuild test \
    -project Operations.xcodeproj \
    -scheme "Operations Mac" \
    -destination "platform=OS X,arch=x86_64" \
    | xcpretty && exit ${PIPESTATUS[0]}


