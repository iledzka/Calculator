//
//  GraphDrawer.swift
//  GraphingCalculator
//
//  Created by Iza Ledzka on 10/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    // Public API
    
    @IBInspectable
    var scale: CGFloat = 1.0 {
        didSet {
            axes.contentScaleFactor = scale
            graph.contentScaleFactor = scale
            setNeedsDisplay()
        }
    }
    var centerOfAxes: CGPoint = CGPoint() { didSet { resetOrigin = false; setNeedsDisplay() } }
    var pointsPerUnit: CGFloat = 50
    
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed,.ended:
            scale *= pinchRecognizer.scale
            pointsPerUnit *= scale
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

        createAxes(in: rect)
        graph.drawGraph(in: rect, origin: centerOfAxes, screenScaleFactor: UIScreen.main.scale, pointsPerUnit: pointsPerUnit).stroke()
        
    }

}

