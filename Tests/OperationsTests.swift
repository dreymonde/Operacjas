//
//  OperacjasTests.swift
//  OperacjasTests
//
//  Created by Oleg Dreyman on 29.04.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import XCTest
@testable import Operacjas

class OperacjasTests: XCTestCase {
    
    let queue = OperacjaQueue()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegularBuilder() {
        let expectation = self.expectation(description: "Operacja waiting")
        let operation = BlockOperacja {
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
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testBuilderWithFinished() {
        let expectation = self.expectation(description: "Operacja waiting")
        let operation = BlockOperacja {
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
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
}
