//
//  MutualExclusivityCategory.swift
//  Operacjas
//
//  Created by Oleg Dreyman on 08.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public protocol MutualExclusivityCategory {
    
    var categoryIdentifier: String { get }
    
}

extension MutualExclusivityCategory where Self : RawRepresentable, Self.RawValue == String {
    
    public var categoryIdentifier: String {
        return "\(Self.self):\(rawValue)"
    }
    
}
