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
        
        let operationA = BlockOperacja.onMain {
            print("First")
        }
        operationA.setMutuallyExclusive(in: Category.A)
        
        let expectation = self.expectation(description: "Waiting for second operation")
        let operationB = BlockOperacja.onMain {
            print("Second")
            expectation.fulfill()
        }
        operationB.setMutuallyExclusive(in: Category.A)
        operationB.observe { operation in
            operation.didStart {
                if !operationA.isFinished {
                    XCTFail()
                }
                print(operationA.isFinished)
            }
        }
        queue.addOperation(operationA)
        queue.addOperation(operationB)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
}
