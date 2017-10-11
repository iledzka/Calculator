//
//  GraphDrawer.swift
//  GraphingCalculator
//
//  Created by Iza Ledzka on 10/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView, UIGestureRecognizerDelegate {
    
    // Public API

    var mathOperation: CalculatorBrain.PropertyList?
    
    @IBInspectable
    var scale: CGFloat = 1 {
        didSet {
            axes.contentScaleFactor = scale
            graph.contentScaleFactor = scale
            setNeedsDisplay()
        }
    }
    var centerOfAxes: CGPoint = CGPoint() {
        didSet {
            resetOrigin = false
            setNeedsDisplay()
        }
    }
    var pointsPerUnit: CGFloat = 50 { didSet { setNeedsDisplay() }}
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer {
            if pointsPerUnit.isLess(than: 10) {
                pointsPerUnit = 10
                return false
            } else if pointsPerUnit > 500 {
                pointsPerUnit = 500
                return false
            }
        }
        return true
    }
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        pinchRecognizer.delegate = self
        switch pinchRecognizer.state {
        case .changed,.ended:
            var tempScale = scale
            tempScale *= pinchRecognizer.scale
            let scaleBoundaries = max(10, min(tempScale * pointsPerUnit, 500))
            pointsPerUnit = scaleBoundaries
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    func panGraphAround(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed,.ended:
            let translation = panRecognizer.translation(in: self)
            centerOfAxes = CGPoint(x: centerOfAxes.x + translation.x, y: centerOfAxes.y + translation.y)
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    
    
   
    // Private API
    
    
    private var resetOrigin: Bool = true { didSet { if resetOrigin { setNeedsDisplay() } } }
    private var axes = AxesDrawer()
    private var graph = GraphDrawer()
    
    private func createAxes(in rect: CGRect) {
       
        if resetOrigin {
            centerOfAxes = center
        }

        axes.drawAxes(in: rect, origin: centerOfAxes, pointsPerUnit: pointsPerUnit)
    }
    
    override func draw(_ rect: CGRect) {
        print("DRAWING OIN GRAPHVIEW!!!DRAWING OIN GRAPHVIEW!!!DRAWING OIN GRAPHVIEW!!!DRAWING OIN GRAPHVIEW!!!DRAWING OIN GRAPHVIEW!!!")
        createAxes(in: rect)
        if mathOperation != nil {
            graph.drawGraph(in: rect, for: mathOperation!, origin: centerOfAxes, pointsPerUnit: pointsPerUnit).stroke()
            
        }
        
        
    }

}

