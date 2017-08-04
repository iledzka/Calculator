//
//  PrecedenceBinaryTree.swift
//  Calculator
//
//  Created by Iza Ledzka on 24/07/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import Foundation

public indirect enum PrecedenceBinaryTree<T> {
    case node(PrecedenceBinaryTree, T, PrecedenceBinaryTree)
    case empty
    
    public func count() -> Int {
        switch self {
        case .node(let left, _, let right):
            return left.count() + 1 + right.count()
        case .empty:
            return 0
        }
    }
}

extension PrecedenceBinaryTree: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .node(left, value, right):
            return "value: \(value), left = [\(left.description)], right = [\(right.description)]"
        case .empty:
            return ""
        }
    }
}

extension PrecedenceBinaryTree {
    public func traverseInOrder(process: (T) -> Void) {
        if case let .node(left, value, right) = self {
            left.traverseInOrder(process: process)
            process(value)
            right.traverseInOrder(process: process)
        }
    }
}
