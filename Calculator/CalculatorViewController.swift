//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Iza Ledzka on 29/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    weak var delegate: UISplitViewControllerDelegate?
    override func viewDidLoad() {
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

    //Displays result of calculation.
    @IBOutlet weak var display: UILabel!
    //Displays the operations entered so far.
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    @IBAction func graphButtonFlash(_ sender: RoundButton) {
        sender.flash()
    }
    
    var userIsInTheMiddleOfTyping: Bool = false
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func standardToScientificButton(_ sender: RoundButton) {
        sender.flash()
        if brain.scientificButtonIsOn == true {
            brain.scientificButtonIsOn = false
            sender.isSelected = false
            sender.backgroundColor = UIColor.lightGray
        } else {
            brain.scientificButtonIsOn = true
            sender.isSelected = true
            sender.backgroundColor = UIColor.darkGray
        }
    }
    @IBAction func touchDigit(_ sender: RoundButton) {
        sender.flash()
        
            
        
        let digit = sender.currentTitle
        let backspaceButton = sender.currentImage?.isEqual(UIImage(named: "backspace"))
        
        let textCurrentlyInDisplay = display.text!
        
        if backspaceButton != nil {
            if display.text == "0" {
                if brain.variablesForProgram.isEmpty {
                    brain.removeLastOperation()
                    save()
                    restore()
                } else {
                    let _ = brain.variablesForProgram.pop()
                }
            }
            display.text = textCurrentlyInDisplay.dropLast()
            if textCurrentlyInDisplay.dropLast() == "" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }
            
        } else if let unwrappedDigit = digit {
            display.text = textCurrentlyInDisplay.contains(".") && unwrappedDigit.contains(".") ? textCurrentlyInDisplay : textCurrentlyInDisplay + unwrappedDigit.formatted()
        }
        if !userIsInTheMiddleOfTyping {
            if backspaceButton == nil {
                if (digit?.contains("."))! {
                    display.text = "0" + digit!
                }else {
                    display.text =  digit?.formatted()
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
            return true
        }
        return false
    }
    
    
    var displayValue: Double {
        get {
            return Double(display.text!) ?? 0
        }
        set {
            display.text = newValue.formatted()
        }
    }
    
    
    private var brain = CalculatorBrain()
    
    @IBOutlet weak var exponentButton: UIButton!
    @IBAction func performOperation(_ sender: RoundButton) {
        sender.flash()
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
    
    @IBAction func setVariable(_ sender: RoundButton) {
        sender.flash()
        if let variableName = sender.currentTitle {
            let index = variableName.index(after: variableName.startIndex)
            let substring = variableName.substring(from: index)
            brain.variablesForProgram.push((substring, displayValue))
            userIsInTheMiddleOfTyping = false
        }
    }
    
    @IBAction func addVariable(_ sender: RoundButton) {
        sender.flash()
        if let variableName = sender.currentTitle, !userIsInTheMiddleOfTyping {
            brain.setOperandFrom(saved: variableName)
            display.text = variableName
        }
        updateDescriptionLabel()
    }
    
    @IBAction func save(_ sender: RoundButton) {
        sender.flash()
        savedProgram = brain.program
    }
    
    @IBAction func restore(_ sender: RoundButton) {
        sender.flash()
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result ?? 0.0
            updateDescriptionLabel()
        }
    }
    
    
    func doEvaluate(with expression: AnyObject) {
        brain.program = expression
    }
    
    //Save and Restore are used to save the state of program before performorming segue to GraphView
    private func save() {
        savedProgram = brain.program
    }
    private func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result ?? 0.0
            updateDescriptionLabel()
        }
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
