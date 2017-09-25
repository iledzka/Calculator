//
//  ViewController.swift
//  Calculator
//
//  Created by Iza Ledzka on 29/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping: Bool = false
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func standardToScientificButton(_ sender: UIButton) {
        if brain.scientificButtonIsOn == true {
            brain.scientificButtonIsOn = false
            sender.isSelected = false
        } else {
            brain.scientificButtonIsOn = true
            sender.isSelected = true
        }
    }
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        let textCurrentlyInDisplay = display.text!
        
        if digit.contains("⇦") {
            if display.text == "0" {
                brain.removeLastOperation()
                save()
                restore()
            }
            display.text = textCurrentlyInDisplay.dropLast()
            if textCurrentlyInDisplay.dropLast() == "" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }
            
        } else {
            display.text = (textCurrentlyInDisplay.contains(".") && digit.contains(".")) ? textCurrentlyInDisplay : textCurrentlyInDisplay + digit.formatted()
        }
        if !userIsInTheMiddleOfTyping {
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if segue.identifier == "Show Graph", let graphViewController = destinationViewController as? GraphViewController {
            graphViewController.mathOperation = brain.program
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Show Graph" {
            if brain.resultIsPending || brain.result == nil {
                return false
            }
        }
        return true
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
    
    @IBOutlet weak var exponentButton: UIButton!
    @IBAction func performOperation(_ sender: UIButton) {
        if sender.currentTitle == "xʸ" {
            sender.isSelected = true
        } else {
            exponentButton.isSelected = false
        }
        
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
            display.text = "0"
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
        updateDescriptionLabel()
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
    
    //GraphDelegate
    func doEvaluate(with expression: AnyObject) {
        brain.program = expression
    }
    private func updateDescriptionLabel() {
        if brain.resultIsPending {
            descriptionDisplay.text = (brain.description ?? "0") + "..."
        } else if brain.result != nil {
            descriptionDisplay.text = (brain.description ?? "0") + "="
        } else {
            descriptionDisplay.text = "0"
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
