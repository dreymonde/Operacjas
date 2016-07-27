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

public enum DependencyError<Error: ErrorType> {
    case Native(Error)
    case Foreign(ErrorType)
    
    public var native: Error? {
        switch self {
        case let .Native(error):
            return error
        default:
            return nil
        }
    }
}

public enum ErrorResolvingDisposition {
    case Execute
    case FailWithSame
    case Fail(with: ErrorType)
}

public protocol OperationErrorResolver {
    associatedtype Error: ErrorType
    
    func resolve(error: DependencyError<Error>) -> ErrorResolvingDisposition
}

