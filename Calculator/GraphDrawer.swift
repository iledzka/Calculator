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
    
    init(color: UIColor = UIColor.black, contentScaleFactor: CGFloat = 1) {
        self.color = color
        self.contentScaleFactor = contentScaleFactor
}
    func drawGraph(in rect: CGRect, origin: CGPoint, screenScaleFactor: CGFloat, pointsPerUnit: CGFloat) -> UIBezierPath {
        
        let path = UIBezierPath()
        let expression: ((CGFloat) -> CGFloat) = sin
        
        var point = CGPoint(x: rect.minX, y: origin.y)
        
        let numberOfPixels = (rect.maxX - rect.minX) * screenScaleFactor
        
        for pixel in 0...Int(numberOfPixels) {
            let y = expression((CGFloat(pixel) - origin.x) / pointsPerUnit) * pointsPerUnit * -1
            if y.isNormal && !y.isZero {
                point = CGPoint(x: CGFloat(pixel), y: (y * contentScaleFactor) + origin.y)
            }
            if !path.isEmpty {
                path.addLine(to: point)
            }
            path.move(to: point)
        }
        return path
    }
}
