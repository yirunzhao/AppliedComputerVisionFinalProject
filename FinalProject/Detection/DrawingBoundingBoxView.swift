//
//  ClassificationViewController.swift
//  FinalProject
//
//  Created by Yirun Zhao on 2020/5/4.
//  Copyright © 2020 Yirun Zhao. All rights reserved.
//

import UIKit
import Vision

class DrawingBoundingBoxView: UIView {
    
    // set color
    static private var colors: [String: UIColor] = [:]
    
    // choose label color
    public func labelColor(with label: String) -> UIColor {
        if let color = DrawingBoundingBoxView.colors[label] {
            return color
        } else {
            let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 0.8)
            DrawingBoundingBoxView.colors[label] = color
            return color
        }
    }
    
    // predict locations
    public var predictedObjects: [VNRecognizedObjectObservation] = [] {
        didSet {
            self.drawBoxs(with: predictedObjects)
            self.setNeedsDisplay()
        }
    }
    
    // draw boxes
    func drawBoxs(with predictions: [VNRecognizedObjectObservation]) {
        subviews.forEach({ $0.removeFromSuperview() })
        
        for prediction in predictions {
            createLabelAndBox(prediction: prediction)
        }
    }
    
    
    func createLabelAndBox(prediction: VNRecognizedObjectObservation) {
        let labelString: String? = prediction.label
        let color: UIColor = labelColor(with: labelString ?? "N/A")
        
        let scale = CGAffineTransform.identity.scaledBy(x: bounds.width, y: bounds.height)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let bgRect = prediction.boundingBox.applying(transform).applying(scale)
        
        // 创建bgView并加入到当前DBBview中
        let bgView = UIView(frame: bgRect)
        bgView.layer.borderColor = color.cgColor
        bgView.layer.borderWidth = 4
        bgView.backgroundColor = UIColor.clear
        addSubview(bgView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        label.text = labelString ?? "N/A"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black
        label.backgroundColor = color
        label.sizeToFit()
        label.frame = CGRect(x: bgRect.origin.x, y: bgRect.origin.y - label.frame.height,
                             width: label.frame.width, height: label.frame.height)
        addSubview(label)
    }
}

extension VNRecognizedObjectObservation {
    var label: String? {
        return self.labels.first?.identifier
    }
}

extension CGRect {
    func toString(digit: Int) -> String {
        let xStr = String(format: "%.\(digit)f", origin.x)
        let yStr = String(format: "%.\(digit)f", origin.y)
        let wStr = String(format: "%.\(digit)f", width)
        let hStr = String(format: "%.\(digit)f", height)
        return "(\(xStr), \(yStr), \(wStr), \(hStr))"
    }
}
