//
//  VitalOperationsTests.swift
//  DriftOperations
//
//  Created by Oleg Dreyman on 04.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operations

class VitalOperationsTests: XCTestCase {

    func testVitalOperation() {
        let testQueue = DriftOperationQueue()
        let importantPrinter = BlockDriftOperation {
            print("I am so freaking important so I'll make anyone wait for me, bitches")
        }
        testQueue.addOperation(importantPrinter, options: [.Vital])
        let expectation = self.expectation(description: "Waiting for next operation to start")
        let lessImportantPrinter = BlockDriftOperation {
            print("I am just a regular printer")
        }
        lessImportantPrinter.observe { operation in
            operation.didStart {
                if !importantPrinter.isFinished {
                    XCTFail("This operation should wait for vitals")
                }
            }
            operation.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(lessImportantPrinter)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testMultipleVitals() {
        let testQueue = DriftOperationQueue()
        var last = -1
        for index in 0 ... 5 {
            let important = BlockDriftOperation {
                XCTAssertEqual(last, index - 1)
                print("I am so \(index) important")
                last = index
            }
            testQueue.addDependency(important)
            testQueue.addOperation(important)
        }
        let expectation = self.expectation(description: "Waiting for start of non-vital operation")
        let nonImportant = BlockDriftOperation {
            print("Regular is my style")
        }
        nonImportant.observe {
            $0.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(nonImportant)
        waitForExpectations(timeout: 8.0, handler: nil)
    }
    
    func testWithAddOperationVitalTrue() {
        let testQueue = DriftOperationQueue()
        let importantPrinter = BlockDriftOperation {
            print("I am so freaking important so I'll make anyone wait for me, bitches")
        }
        testQueue.addOperation(importantPrinter, options: [.Vital])
        let expectation = self.expectation(description: "Waiting for next operation to start")
        let lessImportantPrinter = BlockDriftOperation {
            print("I am just a regular printer")
        }
        lessImportantPrinter.observe { operation in
            operation.didStart {
                if !importantPrinter.isFinished {
                    XCTFail("This operation should wait for vitals")
                }
            }
            operation.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(lessImportantPrinter)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testWithMultipleQueues() {
        let one = DriftOperationQueue()
        let two = DriftOperationQueue()
        
        let importantPrinter = BlockDriftOperation {
            print("Look at me, I am extra super-duper important")
        }
        
        let expectation = self.expectation(description: "Waiting for waiter")
        let waiter = BlockDriftOperation {
            print("I'm here")
            expectation.fulfill()
        }
        waiter.observe {
            $0.didStart {
                guard importantPrinter.isFinished else {
                    XCTFail("You should wait, young man!")
                    return
                }
            }
        }
        one.addOperation(importantPrinter)
        two.addDependency(importantPrinter)
        two.addOperation(waiter)
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
