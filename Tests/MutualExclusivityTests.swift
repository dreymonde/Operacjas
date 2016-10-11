//
//  MutualExclusivityTests.swift
//  Operacjas
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation
import XCTest
@testable import Operacjas

class MutualExclusivityTests: XCTestCase {
    
    let queue = OperacjaQueue()
    
    func testMutually() {
        enum Category: String, MutualExclusivityCategory {
            case A
            case B
        }
        
        let operationA = BlockOperacja {
            print("First")
        }
        operationA.setMutuallyExclusive(inCategory: Category.A)
        
        let expectation = expectationWithDescription("Waiting for second operation")
        let operationB = BlockOperacja {
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
