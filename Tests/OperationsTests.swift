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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBuilder() {
        let expectation = expectationWithDescription("Operation waiting")
        let operation = BlockOperation {
            print("here")
        }
        operation.observe {
            $0.didStart {
                print("Started")
            }
            $0.didFinish {
                expectation.fulfill()
            }
            $0.didFailed { errors in
                print(errors)
            }
        }
        queue.addOperation(operation)
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
}
