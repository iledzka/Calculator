//
//  DetailViewController.swift
//  GraphingCalculator
//
//  Created by Iza Ledzka on 10/06/2017.
//  Copyright © 2017 Iza Ledzka. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {


    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let pinchRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.changeScale(byReactingTo:)))
            graphView.addGestureRecognizer(pinchRecognizer)
            let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.panGraphAround(byReactingTo:)))
            panRecognizer.minimumNumberOfTouches = 1
            panRecognizer.maximumNumberOfTouches = 1
            graphView.addGestureRecognizer(panRecognizer)
        }
    }
}

