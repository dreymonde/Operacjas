//
//  QueueModuleTests.swift
//  Operations
//
//  Created by Oleg Dreyman on 04.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operations

class QueueModuleTests: XCTestCase {
    
    func testBasicModule() {
        let testQueue = OperationQueue()
        let expectation = expectationWithDescription("Operation is running")
        testQueue.addEnqueuingModule { operation, queue in
            operation.observe {
                $0.didSuccess {
                    print("I'm ready")
                    expectation.fulfill()
                }
            }
        }
        let testPrinter = BlockOperation {
            print("I'm blocked :)")
        }
        testQueue.addOperation(testPrinter)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

}
