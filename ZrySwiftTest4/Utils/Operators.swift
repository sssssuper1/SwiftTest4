//
//  Operators.swift
//  ZrySwiftTest4
//
//  Created by Edison on 2018/8/7.
//  Copyright © 2018年 Edison. All rights reserved.
//

import Foundation

public extension SignedInteger {
    
    /// Increment this SignedInteger by 1
    public mutating func increment() {
        self = self.advanced(by: 1)
    }
    
    /// Decrement this SignedInteger by 1
    public mutating func decrement() {
        self = self.advanced(by: -1)
    }
    
}

prefix operator ++=
postfix operator ++=
prefix operator --=
postfix operator --=

/// Increment this SignedInteger and return the new value
public prefix func ++= <T: SignedInteger>(v: inout T) -> T {
    v.increment()
    return v
}

/// Increment this SignedInteger and return the old value
public postfix func ++= <T: SignedInteger>(v: inout T) -> T {
    let result = v
    v.increment()
    return result
}

/// Decrement this SignedInteger and return the new value
public prefix func --= <T: SignedInteger>(v: inout T) -> T {
    v.decrement()
    return v
}

/// Decrement this SignedInteger and return the old value
public postfix func --= <T: SignedInteger>(v: inout T) -> T {
    let result = v
    v.decrement()
    return result
}
