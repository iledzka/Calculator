//
//  StackMachine.swift
//  Calculator
//
//  Created by Iza Ledzka on 08/08/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import Foundation

struct StackMachine<Double> {
    fileprivate var values = [Double]()
    
    mutating func push(_ element: Double) {
        values.append(element)
    }
    
    mutating func pop() -> Double?{
        return values.popLast()
    }
    
    func topValue() -> Double? {
        return values.last
    }
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
}
