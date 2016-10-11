//
//  QueueModuleTests.swift
//  Operacjas
//
//  Created by Oleg Dreyman on 04.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operacjas

class QueueModuleTests: XCTestCase {
    
    func testBasicModule() {
        let testQueue = OperacjaQueue()
        let expectation = self.expectation(description: "Operacja is running")
        testQueue.addEnqueuingModule { operation, queue in
            operation.observe { (builder: inout BuilderObserver) in
                builder.didSuccess {
                    print("I'm ready")
                    expectation.fulfill()
                }
            }
        }
        let testPrinter = BlockOperacja {
            print("I'm blocked :)")
        }
        testQueue.addOperation(testPrinter)
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
