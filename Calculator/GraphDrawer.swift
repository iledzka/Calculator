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
    private var brain = CalculatorBrain()
    
    init(color: UIColor = UIColor.black, contentScaleFactor: CGFloat = 1) {
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    mutating func drawGraph(in rect: CGRect, for expression: CalculatorBrain.PropertyList, origin: CGPoint, pointsPerUnit: CGFloat) -> UIBezierPath {
        var points = [CGFloat?]()
        let numberOfPixels = (rect.maxX - rect.minX) * UIScreen.main.scale
        
        //resolve mathematical expression
        if let listOfOps = expression as? [AnyObject] {
            for op in listOfOps {
                if let variable = op as? String {
                    if variable.contains("M") {
                        let xAxis = (rect.maxX - rect.minX) / pointsPerUnit
                        let positiveX = xAxis - (origin.x / pointsPerUnit)
                        var negativeX = (xAxis - positiveX) * -1
                        let incrementVal = xAxis / numberOfPixels
                        negativeX -= incrementVal
                        
                        for _ in 0...Int(numberOfPixels) {
                            negativeX += incrementVal
                            
                            //assign values to variable (if not set)
                            let newExpression = listOfOps.map { element -> AnyObject in
                                if element as? String == variable {
                                    return Double(negativeX) as AnyObject
                                } else {
                                    return element
                                }
                            }
                            
                            brain.program = newExpression as CalculatorBrain.PropertyList
                            
                            points.append(CGFloat((brain.result)!))
                        }
                    }
                }
            }
        }
        let path = UIBezierPath()
        
        var point: CGPoint?
        
        if !points.isEmpty {
            for pixel in 0...Int(numberOfPixels) {
                if points[pixel] != nil {
                    let y = points[pixel]! * pointsPerUnit * -1
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
