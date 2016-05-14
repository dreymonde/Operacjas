/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the error codes and convenience functions for interacting with Operation-related errors.
*/

import Foundation

public enum OperationError: Int, ErrorType {
    case ConditionFailed = 1
    case ExecutionFailed = 2
}
