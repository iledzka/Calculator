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
    public func traversePostOrder(process: (T) -> Void) {
        if case let .node(left, value, right) = self {
            left.traversePostOrder(process: process)
            right.traversePostOrder(process: process)
            process(value)
        }
    }
}

extension PrecedenceBinaryTree {
    public func associatedValues() -> (left: PrecedenceBinaryTree, middle: T, right: PrecedenceBinaryTree)? {
        if case let .node(left, middle, right) = self {
            return (left, middle, right)
        } else {
            return nil
        }
    }
}
