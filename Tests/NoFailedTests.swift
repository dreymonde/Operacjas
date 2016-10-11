//
//  NoFailedTests.swift
//  Operacjas
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation
import XCTest
@testable import Operacjas

class NoFailedTests: XCTestCase {
    
    let queue = OperacjaQueue()
    
    class FailOperacja: Operacja, Fallible {
        enum Error: ErrorType {
            case JustGoAway
        }
        override func execute() {
            finish(withError: .JustGoAway)
        }
    }
    class NoFailOperacja: Operacja {
        override func execute() {
            print("No fail")
            finish()
        }
    }
    
    func testNoFailed() {
        let fail1 = FailOperacja()
        let noFail1 = NoFailOperacja()
        
        let expectation = expectationWithDescription("No Fail Main")
        let noFailMain = NoFailOperacja()
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
        let fail1 = FailOperacja()
        let noFail1 = NoFailOperacja()
        
        let expectation = expectationWithDescription("No Fail Main")
        let noFailMain = NoFailOperacja()
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
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    class FailOperationTwo: Operacja, Fallible, ErrorInformer {
        enum Error: ErrorType {
            case JustGoAway
            case JustSomeInfo
        }
        override func execute() {
            finish(withError: .JustSomeInfo)
        }
        func purpose(of error: ErrorType) -> ErrorPurpose {
            if error == Error.JustSomeInfo {
                return .Informative
            }
            return .Fatal
        }
    }
    
    func testDecider() {
        let fot = FailOperationTwo()
        let noFail = NoFailOperacja()
        let expectation = expectationWithDescription("No Fail Main")
        
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
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}

func == <EqError: ErrorType where EqError: Equatable>(lhs: ErrorType, rhs: EqError) -> Bool {
    if let lhs = lhs as? EqError {
        return lhs == rhs
    }
    return false
}
