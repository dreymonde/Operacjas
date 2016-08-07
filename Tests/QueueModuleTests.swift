//
//  QueueModuleTests.swift
//  DriftOperations
//
//  Created by Oleg Dreyman on 04.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operations

class QueueModuleTests: XCTestCase {
    
    func testBasicModule() {
        let testQueue = DriftOperationQueue()
        let expectation = self.expectation(description: "DriftOperation is running")
        testQueue.addEnqueuingModule { operation, queue in
            operation.observe {
                $0.didSuccess {
                    print("I'm ready")
                    expectation.fulfill()
                }
            }
        }
        let testPrinter = BlockDriftOperation {
            print("I'm blocked :)")
        }
        testQueue.addOperation(testPrinter)
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
