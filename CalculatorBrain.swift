//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Iza Ledzka on 29/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import Foundation

private func factorial(_ value: Double) -> Double {
    guard value < 25 else { return 0 }
    if value <= 1 {
        return value
    } else {
        return value * factorial(value-1)
    }
}

private func randomValueFromZeroToOne() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

private func makeExponent(of value: Double) -> (Double) -> Double {
    let base = value
    func addSubscript(exp : Double) -> Double {
        return pow(base, exp)
    }
    return addSubscript
}

private func exponentize(str: String) -> String {
    
    let supers = [
        "1": "\u{00B9}",
        "2": "\u{00B2}",
        "3": "\u{00B3}",
        "4": "\u{2074}",
        "5": "\u{2075}",
        "6": "\u{2076}",
        "7": "\u{2077}",
        "8": "\u{2078}",
        "9": "\u{2079}",
        "0": "\u{2070}",
        ".": "\u{22C5}",
        "(": "\u{207D}",
        ")": "\u{207E}",
        "-": "\u{207B}"]
    
    var newStr = ""
    var isExp = false
    for (_, char) in str.characters.enumerated() {
        if char == "^" {
            isExp = true
        } else {
            if isExp {
                let key = String(char)
                if supers.keys.contains(key) {
                    newStr.append(Character(supers[key]!))
                } else {
                    isExp = false
                    newStr.append(char)
                }
            } else {
                newStr.append(char)
            }
        }
    }
    return newStr
}

struct CalculatorBrain {

// Public API
    
    var variablesForProgram = StackMachine<(String, Double)>()

    var description: String?
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return (pendingBinaryOperation != nil || exponentMaker != nil)
        }
    }
    var scientificButtonIsOn = false
    
    mutating func setOperand(_ operand: Double) {
        if exponentMaker != nil {
            accumulator = exponentMaker!(operand)
            exponentString = exponentString! + "^" + operand.formatted()
            resultsArray.append((accumulator!, exponentize(str: exponentString!)))
            exponentMaker = nil
            internalProgram.append(operand as AnyObject)
        } else { //if resultsArray.last?.stringValue.contains("M") == false{
            accumulator = operand
            resultsArray.append((accumulator!, accumulator!.formatted()))
            internalProgram.append(accumulator as AnyObject)
        }
    }
    
    mutating func setOperandFrom(saved variable: String) {
        if let (key, value) = variablesForProgram.topValue(){
            assert(key == variable, "Variable doesn't match key in setOperandFrom()")
            accumulator = value
            resultsArray.append((accumulator!, key))
            internalProgram.append(accumulator as AnyObject)
        } else if resultsArray.last?.operand == nil {
            accumulator = 0.0
            resultsArray.append((accumulator, variable))
            internalProgram.append(variable as AnyObject)
        }

    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value, let stringRepresentation):
                if resultsArray.last?.operand == nil {
                    accumulator = value
                    buildBinaryTree(with: value)
                    resultsArray.append((value, stringRepresentation))
                    internalProgram.append(symbol as AnyObject)
                }
            case .unary(let function, let stringRepresentationFunc):
                if accumulator != nil && exponentMaker == nil {
                    let operand = resultsArray.last?.operand
                    let stringValue = resultsArray.last?.stringValue
                    var isNumber: Double?
                    if stringValue != nil {
                        isNumber = Double(stringValue!)
                    }
                    if operand != nil {
                        resultsArray.removeLast()
                    }
                    resultsArray.append((accumulator!, isNumber != nil ? stringRepresentationFunc(accumulator!.formatted()) : stringRepresentationFunc(stringValue ?? accumulator!.formatted())))
                    accumulator = function(accumulator!)
                    buildBinaryTree(with: accumulator!)
                    internalProgram.append(symbol as AnyObject)
                }
            case .binary(let function, let precedenceOfOp):
                if accumulator != nil && exponentMaker == nil{
                    if resultsArray.isEmpty {
                        resultsArray.append((accumulator!, accumulator!.formatted()))
                    }
                    buildBinaryTree(with: accumulator!)
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator!, binaryFunctionDescription: symbol)
                    resultsArray.append((nil, symbol))
                    accumulator = nil
                    previousPrecedence = currentPrecedence
                    currentPrecedence = precedenceOfOp
                    internalProgram.append(symbol as AnyObject)
                } else if variablesForProgram.isEmpty {
                    print("IS EMPTY")
                }
            case .random(let function, let stringRepresentation):
                if resultsArray.last?.operand == nil {
                    accumulator = function()
                    buildBinaryTree(with: accumulator!)
                    resultsArray.append((accumulator!, stringRepresentation(accumulator!.formatted())))
                    internalProgram.append(symbol as AnyObject)
                }
            case .exponent(let function, let baseValueString):
                if accumulator != nil && exponentMaker == nil{
                    var displayedValue = resultsArray.last?.stringValue
                    displayedValue = displayedValue == "M" ? displayedValue : nil
                    if !resultsArray.isEmpty {
                        resultsArray.removeLast()
                    }
                    exponentMaker = function(accumulator!)
                    exponentString = baseValueString(displayedValue ?? accumulator!.formatted())
                    internalProgram.append("xʸ" as AnyObject)
                }
            case .equals:
                guard exponentMaker == nil else { break }
                guard resultIsPending == true else { break }
                buildBinaryTree(with: accumulator ?? 0)
                tree?.traversePostOrder { s in
                    switch s {
                    case is Double:
                        calculationsStack.push(s as! Double)
                        
                    case is String:
                        if let operation = operations[s as! String] {
                            if case .binary(let function, _) = operation {
                                //values need to be passed in reverse order to maintain the order of operations
                                let firstValue = calculationsStack.pop()!
                                let tempResult = function(calculationsStack.pop()!, firstValue )
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
                    pendingBinaryOperation = nil
                }
                internalProgram.append(symbol as AnyObject)
                currentPrecedence = .high
                resultsArray.removeAll()
                
            case .C:
                clear()
            }
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                //count keeps track of the index to resolve xʸ operation.
                var count = 0
                var needToSkipOperation = false
                for op in arrayOfOps {
                    if let numericValue = op as? Double {
                        if needToSkipOperation {
                            needToSkipOperation = false
                            exponentMaker = nil
                            continue
                        }
                        setOperand(numericValue)
                    } else if let stringValue = op as? String {
                        if stringValue.contains("M") {
                            setOperandFrom(saved: stringValue)
                        } else if stringValue.contains("xʸ"){
                            performOperation(stringValue)
                            setOperand((arrayOfOps[arrayOfOps.index(after: count)] as? Double)!)
                            needToSkipOperation = true
                        } else {
                            performOperation(stringValue)
                        }
                    }
                    count = count + 1
                }
            }
        }
    }
    
    mutating func removeLastOperation() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
        }
    }
    
// Private API
    
    private var internalProgram = [AnyObject]() //{ didSet { print("internalProgram: " + internalProgram.description) }}
    
    private var calculationsStack = StackMachine<Double>()
    
    private var accumulator: Double? //{ didSet { print("acc: " + String(describing: accumulator)) } }
    
    private var exponentMaker: ((Double) -> Double)? //{ didSet { print("EXPONENT MARKER changed: " + exponentMaker.debugDescription)}}
    
    private var exponentString: String?
    
    //array of enums used to build description string
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
        case random(() -> Double, (String)->String)
        case exponent((Double) -> (Double) -> (Double), (String) -> String)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "√" : Operation.unary(sqrt, {"√\($0)"}),
        "cos" : Operation.unary(cos, {"cos(\($0))"}),
        "sin" : Operation.unary(sin, {"sin(\($0))"}),
        "x²" : Operation.unary({$0 * $0}, {"\($0)²"}),
        "x!" : Operation.unary(factorial, {"(\($0))!"}),
        "±" : Operation.unary({-$0}, {"(-\($0))"}),
        "xʸ" : Operation.exponent(makeExponent, {"\($0)"}),
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
        internalProgram.removeAll()
        exponentMaker = nil
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
