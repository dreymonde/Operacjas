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
        
        noFailMain.addDependency(fail1, options: [.ExpectSuccess])
        noFailMain.addDependency(noFail1, options: [.ExpectSuccess])
        queue.addOperation(fail1)
        queue.addOperation(noFail1)
        queue.addOperation(noFailMain)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    class JustFail: Operation, Fallible {
        enum Error: ErrorType {
            case A
            case B
            case C
        }
        let error: Error
        init(failWith error: Error) {
            self.error = error
        }
        
        override func execute() {
            finish(with: error)
        }
    }
    
    enum Test: ErrorType {
        case Error
    }
    
    func testResolverFail() {
        let expectation = expectationWithDescription("Block")
        let justFail = JustFail(failWith: .A)
        let block = BlockOperation(mainQueueBlock: { print("Executing") })
        block.addDependency(justFail, resolveError: { error in
            switch error {
            case .Native(let error):
                switch error {
                case .B:
                    return .Execute
                case .A:
                    return .FailWithSame
                case .C:
                    return .Fail(with: Test.Error)
                }
            default:
                return .FailWithSame
            }
        })
        block.observe {
            $0.didStart {
                XCTFail()
            }
            $0.didFail { errors in
                print(errors)
                expectation.fulfill()
            }
        }
        queue.addOperations(justFail, block)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testResolverExecute() {
        let expectation = expectationWithDescription("Block")
        let justFail = JustFail(failWith: .B)
        let block = BlockOperation(mainQueueBlock: { print("Executing") })
        block.addDependency(justFail, resolveError: { error in
            switch error {
            case .Native(let error):
                switch error {
                case .B:
                    return .Execute
                case .A:
                    return .FailWithSame
                case .C:
                    return .Fail(with: Test.Error)
                }
            default:
                return .FailWithSame
            }
        })
        block.observe {
            $0.didFail { errors in
                print(errors)
                XCTFail()
            }
            $0.didSuccess {
                expectation.fulfill()
            }
        }
        queue.addOperations(justFail, block)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    struct JustFailResolver: OperationErrorResolver {
        func resolve(error: DependencyError<JustFail.Error>) -> ErrorResolvingDisposition {
            switch error {
            case .Native(let error):
                switch error {
                case .B:
                    return .Execute
                case .A:
                    return .FailWithSame
                case .C:
                    return .Fail(with: Test.Error)
                }
            default:
                return .FailWithSame
            }
        }
    }
    
    func testReusableFail() {
        let expectation = expectationWithDescription("Block")
        let justFail = JustFail(failWith: .A)
        let block = BlockOperation(mainQueueBlock: { print("Executing") })
        block.addDependency(justFail, errorResolver: JustFailResolver())
        block.observe {
            $0.didStart {
                XCTFail()
            }
            $0.didFail { errors in
                print(errors)
                expectation.fulfill()
            }
        }
        queue.addOperations(justFail, block)
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}
