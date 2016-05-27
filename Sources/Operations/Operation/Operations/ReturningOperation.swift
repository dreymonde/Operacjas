//
//  ReturningOperation.swift
//  Operations
//
//  Created by Oleg Dreyman on 27.05.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public class ReturningOperation<Returned>: Operation {
    
    private var internalValue: Returned?
    public var value: Returned? {
        if finishing {
            return internalValue
        }
        return nil
    }
    
    private var finishing = false
    func finishAndReturn(value: Returned) {
        internalValue = value
        finishing = true
        finish()
    }
    
}
