//
//  MutualExclusivityTests.swift
//  DriftOperations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation
import XCTest
@testable import Operations

class MutualExclusivityTests: XCTestCase {
    
    let queue = DriftOperationQueue()
    
    func testMutually() {
        enum Category: String, MutualExclusivityCategory {
            case A
            case B
        }
        
        let operationA = BlockOperation {
            print("First")
        }
        operationA.setMutuallyExclusive(inCategory: Category.A)
        
        let expectation = expectationWithDescription("Waiting for second operation")
        let operationB = BlockOperation {
            print("Second")
            expectation.fulfill()
        }
        operationB.setMutuallyExclusive(inCategory: Category.A)
        operationB.observe { operation in
            operation.didStart {
                if !operationA.finished {
                    XCTFail()
                }
                print(operationA.finished)
            }
        }
        queue.addOperation(operationA)
        queue.addOperation(operationB)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}