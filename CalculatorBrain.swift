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

// Public API
    
    var description: String?
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    var scientificButtonIsOn = false { didSet { print("scientificButtonIsOn changed to \(scientificButtonIsOn)")}}
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        resultsArray.append((accumulator!, "\(accumulator!)"))
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value, let stringRepresentation):
                if resultsArray.last?.operand == nil {
                    accumulator = value
                    buildBinaryTree(with: value)
                    resultsArray.append((value, stringRepresentation))
                }
            case .unary(let function, let stringRepresentationFunc):
                if accumulator != nil {
                    if resultsArray.last?.operand == nil {
                        resultsArray.append((accumulator!,stringRepresentationFunc(accumulator!.formatted())))
                    } else {
                        resultsArray.removeLast()
                        resultsArray.append((accumulator!,stringRepresentationFunc(accumulator!.formatted())))
                    }
                    accumulator = function(accumulator!)
                    buildBinaryTree(with: accumulator!)
                }
            case .binary(let function, let precedenceOfOp):
                if accumulator != nil {
                    if resultsArray.isEmpty {
                        resultsArray.append((accumulator!, "\(accumulator!)"))
                    }
                    buildBinaryTree(with: accumulator!)
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator!, binaryFunctionDescription: symbol)
                    resultsArray.append((nil, symbol))
                    accumulator = nil
                    previousPrecedence = currentPrecedence
                    currentPrecedence = precedenceOfOp
                    
                }
            case .random(let function, let stringRepresentation):
                if resultsArray.last?.operand == nil {
                    accumulator = function()
                    buildBinaryTree(with: accumulator!)
                    resultsArray.append((accumulator!, stringRepresentation(accumulator!)))
                }
            case .equals:
                buildBinaryTree(with: accumulator!)
                tree?.traversePostOrder { s in
                    print(s)
                    switch s {
                    case is Double:
                        calculationsStack.push(s as! Double)
                        
                    case is String:
                        if let operation = operations[s as! String] {
                            if case .binary(let function, _) = operation {
                                //values need to be passed in reverse order to maintain the order of operations
                                let firstValue = calculationsStack.pop()!
                                let tempResult = function(calculationsStack.pop()!, firstValue)
                                calculationsStack.push(tempResult)
                            }
                        }
                    default:
                        break
                    }
                }
                if scientificButtonIsOn == false {
                    performPendingBinaryOperation()
                } else {
                    accumulator = calculationsStack.topValue()
                }
                print("RESULT OF TREE: " + String(describing: calculationsStack.topValue()))
               
                currentPrecedence = .high
                resultsArray.removeAll()
                
            case .C:
                clear()
            }
        }
    }

    
// Private API
    private var calculationsStack = StackMachine<Double>()
    
    private var accumulator: Double? { didSet { print("acc: " + String(describing: accumulator)) } }
    
    private var resultsArray = [(operand: Double?, stringValue: String)]() {
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
        }
    }
    
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
    
        private mutating func clear() {
        accumulator = nil
        description = nil
        resultsArray.removeAll()
        pendingBinaryOperation = nil
        currentPrecedence = .high
        tree = nil
    }
    mutating private func performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    //This struct stores info needed to perform pending operation (uses accumulator).
    private struct PendingBinaryOperation {
        let binaryFunction: (Double,Double)->Double
        let firstOperand: Double
        let binaryFunctionDescription: String
        
        func perform(with secondOperand: Double) -> (Double) {
            return binaryFunction(firstOperand, secondOperand)
        }
    }
    
    
    //Precedence binary tree implementation used when the scientific calculator is on (doen't use accumulator).
    private enum Precedence: Int {
        case low = 0
        case high
    }
    
    private var currentPrecedence = Precedence.high
    private var previousPrecedence = Precedence.high
    
    private var tree: PrecedenceBinaryTree<Any>?
    
    private mutating func buildBinaryTree(with newValue: Any) {
        let tempNode = PrecedenceBinaryTree.node(.empty, newValue, .empty)
        
        if tree == nil {
            tree = tempNode
        }

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
