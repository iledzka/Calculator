//
//  GraphDrawer.swift
//  GraphingCalculator
//
//  Created by Iza Ledzka on 19/08/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//


import UIKit

struct GraphDrawer
{
    var color: UIColor
    var contentScaleFactor: CGFloat
    var lineWidth: CGFloat
    private var brain = CalculatorBrain()
  
    
    init(color: UIColor = UIColor.white, contentScaleFactor: CGFloat = 1, lineWidth: CGFloat = 3) {
        self.color = color
        self.contentScaleFactor = contentScaleFactor
        self.lineWidth = lineWidth
    }
    
    mutating func drawGraph(in rect: CGRect, for expression: CalculatorBrain.PropertyList, origin: CGPoint, pointsPerUnit: CGFloat) -> UIBezierPath {
        
        let numberOfPixels = (rect.maxX - rect.minX) * UIScreen.main.scale
        let xAxis = (rect.maxX - rect.minX) / pointsPerUnit
        let positiveX = xAxis - (origin.x / pointsPerUnit)
        let incrementVal = xAxis / numberOfPixels
        
        let path = UIBezierPath()
        color.set()
        path.lineWidth = lineWidth
        var point: CGPoint?
        
        //resolve mathematical expression
        if let listOfOps = expression as? [AnyObject] {
            
            var negativeX = (xAxis - positiveX) * -1
            negativeX -= incrementVal
            //assign values to variable (if not set)
            for pixel in 0...Int(numberOfPixels - 1) {
                negativeX += incrementVal
                let newExpression = listOfOps.map { element -> AnyObject in
                    if element as? String == "M" {
                        
                        return Double(negativeX) as AnyObject
                    } else {
                        return element
                    }
                }
                
                brain.program = newExpression as CalculatorBrain.PropertyList
                
                if let result = brain.result {
                    
                    let y = CGFloat(result) * pointsPerUnit * -1
                    if y.isNormal && !y.isZero {
                        point = CGPoint(x: CGFloat(pixel) / UIScreen.main.scale, y: y + origin.y)
                    }
                    if let unwrappedPoint = point {
                        if !path.isEmpty {
                            path.addLine(to: unwrappedPoint)
                        }
                        path.move(to: unwrappedPoint)
                    }
                }
            }
        }
        return path
    }
}
