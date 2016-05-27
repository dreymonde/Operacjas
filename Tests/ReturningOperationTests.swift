//
//  ReturningOperationTests.swift
//  Operations
//
//  Created by Oleg Dreyman on 27.05.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operations
import Foundation

class ReturningOperationTests: XCTestCase {
    
    let queue = OperationQueue()
    
    func testReturningOperation() {
        
        let expectation = expectationWithDescription("Operation")
        
        class TestOperation: ReturningOperation<Int> {
            let number: Int
            init(number: Int) {
                self.number = number
            }
            override func execute() {
                let newNumber = number * 10
                finishAndReturn(newNumber)
            }
        }
        
        let test = TestOperation(number: 5)
        test.observe { operation in
            operation.didSuccess {
                print(test.value)
                XCTAssertEqual(test.value!, 50)
                expectation.fulfill()
            }
        }
        
        queue.addOperation(test)
        waitForExpectationsWithTimeout(2.0, handler: nil)
        
    }
    
}
