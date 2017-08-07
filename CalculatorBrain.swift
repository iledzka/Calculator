//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Iza Ledzka on 29/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import Foundation

private func factorial(_ value: Double) -> Double {
    if value <= 1 {
        return value
    } else {
        return value * factorial(value-1)
    }
}

private func randomValueFromZeroToOne() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

struct CalculatorBrain {
    
    private var accumulator: Double? { didSet { print("acc: " + String(describing: accumulator)) } }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    private var resultsArray = [(operand: Double?, stringValue: String, previousResult: Double?)]() {
        willSet {
            if let lastElement = newValue.last {
                if description == nil {
                    description = String()
                }
                if newValue.count > resultsArray.count {
                    description?.removeAll()
                    for stringValues in newValue {
                        description = description! + stringValues.stringValue.formatted()
                    }
                } else {
                    description?.append(lastElement.stringValue.formatted())
                }
                
            }
            print("resultsArray: " + resultsArray.debugDescription)
            //print(description.debugDescription)
        }
    }
    
    var description: String?
    
    private enum Operation {
        case constant(Double, String)
        case unary((Double) -> Double, (String) -> String)
        case binary((Double,Double)->Double, Precedence)
        case equals
        case C
        case random(() -> Double, (Double)->String)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "√" : Operation.unary(sqrt, {"√(\($0))"}),
        "cos" : Operation.unary(cos, {"cos(\($0))"}),
        "sin" : Operation.unary(sin, {"sin(\($0))"}),
        "x²" : Operation.unary({$0 * $0}, {"(\($0))²"}),
        "x!" : Operation.unary(factorial, {"(\($0))!"}),
        "±" : Operation.unary({-$0}, {"(\(-1 * Double($0)!))"}),
        "×" : Operation.binary(*, .high),
        "÷" : Operation.binary(/, .high),
        "+" : Operation.binary(+, .low),
        "−" : Operation.binary(-, .low),
        "=" : Operation.equals,
        "C" : Operation.C,
        "rand" : Operation.random(randomValueFromZeroToOne, {"\($0)"})
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value, let stringRepresentation):
                if resultsArray.last?.operand == nil {
                    accumulator = value
                    resultsArray.append((value, stringRepresentation, nil))
                }
            case .unary(let function, let stringRepresentationFunc):
                if accumulator != nil {
                    if resultsArray.last?.operand == nil {
                        resultsArray.append((accumulator!,stringRepresentationFunc(accumulator!.formatted()), nil))
                    } else {
                        resultsArray.removeLast()
                        resultsArray.append((accumulator!,stringRepresentationFunc(accumulator!.formatted()), nil))
                    }
                    accumulator = function(accumulator!)
                }
            case .binary(let function, let precedenceOfOp):
                if accumulator != nil {
                    if resultsArray.isEmpty {
                        resultsArray.append((accumulator!, "\(accumulator!)", nil))
                    }
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator!, binaryFunctionDescription: symbol)
                    resultsArray.append((nil, symbol, nil))
                    accumulator = nil
                    previousPrecedence = currentPrecedence
                    currentPrecedence = precedenceOfOp
                    
                }
            case .random(let function, let stringRepresentation):
                if resultsArray.last?.operand == nil {
                    accumulator = function()
                    resultsArray.append((accumulator!, stringRepresentation(accumulator!), nil))
                } else {
                    
                }
            case .equals:
                print(tree?.description ?? "Can't print the tree's description.")
                performPendingBinaryOperation()
                currentPrecedence = .high
                resultsArray.removeAll()
            case .C:
                clear()
            }
        }
    }
    private mutating func clear() {
        accumulator = nil
        description = nil
        resultsArray.removeAll()
        pendingBinaryOperation = nil
        currentPrecedence = .high
        tree = nil
    }
    mutating func performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let binaryFunction: (Double,Double)->Double
        let firstOperand: Double
        let binaryFunctionDescription: String
        
        func perform(with secondOperand: Double) -> (Double) {
            return binaryFunction(firstOperand, secondOperand)
        }
    }
    
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        resultsArray.append((accumulator!, "\(accumulator!)", nil))
        buildBinaryTree(with: operand)
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    //precedence binary tree implementation
    
    private enum Precedence: Int {
        case low = 0
        case high
    }
    
    private var currentPrecedence = Precedence.high
    private var previousPrecedence = Precedence.high
    
    var tree: PrecedenceBinaryTree<Any>?
    
    private mutating func buildBinaryTree(with newValue: Any) {
        let tempNode = PrecedenceBinaryTree.node(.empty, newValue, .empty)
        
        if tree == nil {
            tree = tempNode
        }
        print("Tree: " + (tree?.description)!)
        print("**************************")
        if pendingBinaryOperation != nil {
            let operation = pendingBinaryOperation?.binaryFunctionDescription
            if currentPrecedence.rawValue > previousPrecedence.rawValue {
                let left = tree?.associatedValues()?.left
                let middle = tree?.associatedValues()?.middle
                let right = tree?.associatedValues()?.right
                tree = PrecedenceBinaryTree<Any>.node(left!, middle!, PrecedenceBinaryTree<Any>.node(right!, operation!, tempNode))
            } else {
                tree = PrecedenceBinaryTree<Any>.node(tree!, operation!, tempNode)
            }
        }
    }
    
}
