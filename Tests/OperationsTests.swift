//
//  OperationsTests.swift
//  OperationsTests
//
//  Created by Oleg Dreyman on 29.04.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operations

class OperationsTests: XCTestCase {
    
    let queue = OperationQueue()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegularBuilder() {
        let expectation = expectationWithDescription("Operation waiting")
        let operation = BlockOperation {
            print("here")
        }
        operation.observe {
            $0.didStart {
                print("Started")
            }
            $0.didSuccess {
                expectation.fulfill()
            }
            $0.didFail { errors in
                print(errors)
            }
        }
        queue.addOperation(operation)
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testBuilderWithFinished() {
        let expectation = expectationWithDescription("Operation waiting")
        let operation = BlockOperation {
            print("here")
        }
        operation.observe {
            $0.didFinishWithErrors { _ in
                expectation.fulfill()
            }
            $0.didSuccess {
                XCTFail()
            }
            $0.didFail { _ in
                XCTFail()
            }
        }
        queue.addOperation(operation)
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
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
