//
//  NoFailedTests.swift
//  Operations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation
import XCTest
@testable import Operations

class NoFailedTests: XCTestCase {
    
    let queue = OperationQueue()
    
    class FailOperation: Operation, Fallible {
        enum Error: ErrorType {
            case JustGoAway
        }
        override func execute() {
            finish(withError: .JustGoAway)
        }
    }
    class NoFailOperation: Operation {
        override func execute() {
            print("No fail")
            finish()
        }
    }
    
    func testNoFailed() {
        let fail1 = FailOperation()
        let noFail1 = NoFailOperation()
        
        let expectation = expectationWithDescription("No Fail Main")
        let noFailMain = NoFailOperation()
        noFailMain.observe { (operation) in
            operation.didFinishWithErrors { errors in
                XCTAssertTrue(!errors.isEmpty)
                debugPrint(errors)
                expectation.fulfill()
            }
        }
        
        noFailMain.addDependencies([fail1, noFail1])
        noFailMain.addCondition(NoFailedDependencies())
        queue.addOperation(fail1)
        queue.addOperation(noFail1)
        queue.addOperation(noFailMain)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testNoFailedOne() {
        let fail1 = FailOperation()
        let noFail1 = NoFailOperation()
        
        let expectation = expectationWithDescription("No Fail Main")
        let noFailMain = NoFailOperation()
        noFailMain.observe { (operation) in
            operation.didFinishWithErrors({ (errors) in
                XCTAssertEqual(errors.count, 1)
                debugPrint(errors)
                expectation.fulfill()
            })
        }
        
        noFailMain.addDependency(fail1, expectSuccess: true)
        noFailMain.addDependency(noFail1, expectSuccess: true)
        queue.addOperation(fail1)
        queue.addOperation(noFail1)
        queue.addOperation(noFailMain)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}
