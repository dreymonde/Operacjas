//
//  VitalOperationsTests.swift
//  Operacjas
//
//  Created by Oleg Dreyman on 04.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operacjas

class VitalOperationsTests: XCTestCase {

    func testVitalOperation() {
        let testQueue = OperacjaQueue()
        let importantPrinter = BlockOperacja {
            print("I am so freaking important so I'll make anyone wait for me, bitches")
        }
        testQueue.addOperation(importantPrinter, options: [.Vital])
        let expectation = expectationWithDescription("Waiting for next operation to start")
        let lessImportantPrinter = BlockOperacja {
            print("I am just a regular printer")
        }
        lessImportantPrinter.observe { operation in
            operation.didStart {
                if !importantPrinter.finished {
                    XCTFail("This operation should wait for vitals")
                }
            }
            operation.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(lessImportantPrinter)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testMultipleVitals() {
        let testQueue = OperacjaQueue()
        var last = -1
        for index in 0 ... 5 {
            let important = BlockOperacja {
                XCTAssertEqual(last, index - 1)
                print("I am so \(index) important")
                last = index
            }
            testQueue.addDependency(important)
            testQueue.addOperation(important)
        }
        let expectation = expectationWithDescription("Waiting for start of non-vital operation")
        let nonImportant = BlockOperacja {
            print("Regular is my style")
        }
        nonImportant.observe {
            $0.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(nonImportant)
        waitForExpectationsWithTimeout(8.0, handler: nil)
    }
    
    func testWithAddOperationVitalTrue() {
        let testQueue = OperacjaQueue()
        let importantPrinter = BlockOperacja {
            print("I am so freaking important so I'll make anyone wait for me, bitches")
        }
        testQueue.addOperation(importantPrinter, options: [.Vital])
        let expectation = expectationWithDescription("Waiting for next operation to start")
        let lessImportantPrinter = BlockOperacja {
            print("I am just a regular printer")
        }
        lessImportantPrinter.observe { operation in
            operation.didStart {
                if !importantPrinter.finished {
                    XCTFail("This operation should wait for vitals")
                }
            }
            operation.didSuccess {
                expectation.fulfill()
            }
        }
        testQueue.addOperation(lessImportantPrinter)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testWithMultipleQueues() {
        let one = OperacjaQueue()
        let two = OperacjaQueue()
        
        let importantPrinter = BlockOperacja {
            print("Look at me, I am extra super-duper important")
        }
        
        let expectation = expectationWithDescription("Waiting for waiter")
        let waiter = BlockOperacja {
            print("I'm here")
            expectation.fulfill()
        }
        waiter.observe {
            $0.didStart {
                guard importantPrinter.finished else {
                    XCTFail("You should wait, young man!")
                    return
                }
            }
        }
        one.addOperation(importantPrinter)
        two.addDependency(importantPrinter)
        two.addOperation(waiter)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

}
