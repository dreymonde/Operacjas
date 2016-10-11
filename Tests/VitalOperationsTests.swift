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
        let importantPrinter = BlockOperacja.onMain {
            print("I am so freaking important so I'll make anyone wait for me, bitches")
        }
        testQueue.addOperation(importantPrinter, options: [.vital])
        let expectation = self.expectation(description: "Waiting for next operation to start")
        let lessImportantPrinter = BlockOperacja.onMain {
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
        let testQueue = OperacjaQueue()
        var last = -1
        for index in 0 ... 5 {
            let important = BlockOperacja.onMain {
                XCTAssertEqual(last, index - 1)
                print("I am so \(index) important")
                last = index
            }
            testQueue.addDependency(important)
            testQueue.addOperation(important)
        }
        let expectation = self.expectation(description: "Waiting for start of non-vital operation")
        let nonImportant = BlockOperacja.onMain {
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
        let testQueue = OperacjaQueue()
        let importantPrinter = BlockOperacja.onMain {
            print("I am so freaking important so I'll make anyone wait for me, bitches")
        }
        testQueue.addOperation(importantPrinter, options: [.vital])
        let expectation = self.expectation(description: "Waiting for next operation to start")
        let lessImportantPrinter = BlockOperacja.onMain {
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
        let one = OperacjaQueue()
        let two = OperacjaQueue()
        
        let importantPrinter = BlockOperacja.onMain {
            print("Look at me, I am extra super-duper important")
        }
        
        let expectation = self.expectation(description: "Waiting for waiter")
        let waiter = BlockOperacja.onMain {
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
