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
    
    /// Puts `self` in `finished` state.
    ///
    /// - Parameter error: A case of nested `Error` type.
    public func finish(withError error: Error) {
        finish(with: [error])
    }
    
    /// Marks an operation as `cancelled`.
    ///
    /// - Parameter error: A case of nested `Error` type.
    public func cancel(withError error: Error) {
        cancel(with: error)
    }
    
}