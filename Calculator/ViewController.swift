//
//  ViewController.swift
//  Calculator
//
//  Created by Iza Ledzka on 29/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping: Bool = false
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func standardToScientificButton(_ sender: UIButton) {
        if brain.scientificButtonIsOn == true {
            brain.scientificButtonIsOn = false
            sender.setTitle("Std", for: .normal)
        } else {
            brain.scientificButtonIsOn = true
            sender.setTitle("Sci", for: .normal)
        }
    }
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        let textCurrentlyInDisplay = display.text!
        if userIsInTheMiddleOfTyping {
            if digit.contains("⇦") {
                if textCurrentlyInDisplay.dropLast() == "" {
                    display.text = " "
                    userIsInTheMiddleOfTyping = false
                } else {
                    display.text = textCurrentlyInDisplay.dropLast()
                }
            } else {
                display.text = (textCurrentlyInDisplay.contains(".") && digit.contains(".")) ? textCurrentlyInDisplay : textCurrentlyInDisplay + digit.formatted()
            }
        } else {
            if !digit.contains("⇦") {
                if digit.contains(".") {
                    display.text = "0" + digit
                }else {
                    display.text =  digit.formatted()
                }
                userIsInTheMiddleOfTyping = true
            }
        }
        
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = newValue.formatted()
        }
    }
    
  
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        } else {
            display.text = " "
        }
        updateDescriptionLabel()
        
    }

    @IBAction func setVariable(_ sender: UIButton) {
        if let variableName = sender.currentTitle {
            let index = variableName.index(after: variableName.startIndex)
            let substring = variableName.substring(from: index)
            brain.variablesForProgram.push((substring, displayValue))
            userIsInTheMiddleOfTyping = false
        }
    }

    @IBAction func addVariable(_ sender: UIButton) {
        if let variableName = sender.currentTitle {
            brain.setOperandFrom(saved: variableName)
            display.text = variableName
        }
    }
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result ?? 0.0
            updateDescriptionLabel()
        }
    }
    private func updateDescriptionLabel() {
        if brain.resultIsPending {
            descriptionDisplay.text = (brain.description ?? " ") + "..."
        } else if display.text! != " " {
            descriptionDisplay.text = (brain.description ?? " ") + "="
        } else {
            descriptionDisplay.text = " "
        }
    }
    
   
}

extension Double {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        return formatter.string(from: NSNumber(floatLiteral: self))!
    }
    
   
}

extension String {
    func formatted() -> String {
        if (Double(self) != nil) {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 6
            formatter.minimumFractionDigits = 0
            formatter.minimumIntegerDigits = 1
            let tempDouble = Double(self)
            let nsnum = NSNumber(floatLiteral: tempDouble!)
            return formatter.string(from: nsnum)!
        } else {
            return self
        }
    }
    
    func dropLast(_ n: Int = 1) -> String {
        return String(characters.dropLast(n))
    }
    var dropLast: String {
        return dropLast()
    }
}
