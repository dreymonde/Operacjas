//
//  Fallible.swift
//  DriftOperations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

public protocol Fallible {
    associatedtype ErrorType: Error
}

extension Fallible where Self: DriftOperation {
    
    /// Puts `self` in `finished` state.
    ///
    /// - Parameter error: A case of nested `Error` type.
    public func finish(withError error: ErrorType) {
        finish(withErrors: [error])
    }
    
    /// Marks an operation as `cancelled`.
    ///
    /// - Parameter error: A case of nested `Error` type.
    public func cancel(withError error: ErrorType) {
        cancel(with: error)
    }
    
}

public enum ErrorPurpose {
    case fatal
    case informative
}

public protocol ErrorInformer {
    
    func purpose(of error: Error) -> ErrorPurpose
    
}
