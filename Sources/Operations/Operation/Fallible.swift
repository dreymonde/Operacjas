//
//  Fallible.swift
//  Operations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

public protocol Fallible {
    associatedtype Error: ErrorType
}

extension Fallible where Self: Operation {
    
    public func finish(withError error: Error) {
        finish(with: [error])
    }
    
}