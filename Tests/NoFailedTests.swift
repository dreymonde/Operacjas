//
//  NoFailedTests.swift
//  DriftOperations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation
import XCTest
@testable import Operations

class NoFailedTests: XCTestCase {
    
    let queue = DriftOperationQueue()
    
    class FailOperation: DriftOperation, Fallible {
        enum ErrorType: Error {
            case justGoAway
        }
        override func execute() {
            finish(withError: .justGoAway)
        }
    }
    class NoFailOperation: DriftOperation {
        override func execute() {
            print("No fail")
            finish()
        }
    }
    
    func testNoFailed() {
        let fail1 = FailOperation()
        let noFail1 = NoFailOperation()
        
        let expectation = self.expectation(description: "No Fail Main")
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
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testNoFailedOne() {
        let fail1 = FailOperation()
        let noFail1 = NoFailOperation()
        
        let expectation = self.expectation(description: "No Fail Main")
        let noFailMain = NoFailOperation()
        noFailMain.observe { (operation) in
            operation.didFinishWithErrors({ (errors) in
                XCTAssertEqual(errors.count, 1)
                debugPrint(errors)
                expectation.fulfill()
            })
        }
        
        noFailMain.addDependency(fail1, options: [.ExpectSuccess])
        noFailMain.addDependency(noFail1, options: [.ExpectSuccess])
        queue.addOperation(fail1)
        queue.addOperation(noFail1)
        queue.addOperation(noFailMain)
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    class FailOperationTwo: DriftOperation, Fallible, ErrorInformer {
        enum ErrorType: Error {
            case justGoAway
            case justSomeInfo
        }
        override func execute() {
            finish(withError: .justSomeInfo)
        }
        func purpose(of error: Error) -> ErrorPurpose {
            if error == ErrorType.justSomeInfo {
                return .informative
            }
            return .fatal
        }
    }
    
    func testDecider() {
        let fot = FailOperationTwo()
        let noFail = NoFailOperation()
        let expectation = self.expectation(description: "No Fail Main")
        
        noFail.observe {
            $0.didSuccess {
                expectation.fulfill()
            }
            $0.didFail {
                debugPrint($0)
                XCTFail()
            }
        }
        noFail.addDependency(fot, options: [.ExpectSuccess])
        queue.addOperations(fot, noFail)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
}

func == <EqError: Error where EqError: Equatable>(lhs: Error, rhs: EqError) -> Bool {
    if let lhs = lhs as? EqError {
        return lhs == rhs
    }
    return false
}
