//
//  StackMachine.swift
//  Calculator
//
//  Created by Iza Ledzka on 08/08/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import Foundation

struct StackMachine<T> {
    fileprivate var values = [T]()
    
    mutating func push(_ element: T) {
        values.append(element)
    }
    
    mutating func pop() -> T?{
        return values.popLast()
    }
    
    func topValue() -> T? {
        return values.last
    }
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
}
