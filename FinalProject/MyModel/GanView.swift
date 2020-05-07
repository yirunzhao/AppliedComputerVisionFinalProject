//
//  GanView.swift
//  FinalProject
//
//  Created by Yirun Zhao on 2020/5/5.
//  Copyright © 2020 Yirun Zhao. All rights reserved.
//

import UIKit
import Vision


public extension Float {
    static func randomFloatNumber(lower: Float = 0,upper: Float = 100) -> Float {
        return (Float(arc4random()) / Float(UInt32.max)) * (upper - lower) + lower
    }
}

class GanView: UIView {
    @IBInspectable var weight: Double = 1.0 {
        didSet {
          setNeedsDisplay()
        }
      }
    
      private struct Constants {
        static let plusLineWidth: CGFloat = 10.0
        
      }
      
      override func draw(_ rect: CGRect) {

        UIRectFill(rect)

        let m = gan()

        func random() -> Double {
            return Double.random(in: -1.0...1.0)
        }
        
        guard let ganInput = try? MLMultiArray(shape:[100], dataType:MLMultiArrayDataType.double) else {
          fatalError("failt to convert input type")
        }
        
        for i in 0...99 {
            ganInput[i] = NSNumber(value: random())
        }

        guard let out = try? m.prediction(input: ganInput) else {
            fatalError("fail to get prediction result")
        }
        
        
        let HIGHT = 27
        let WIDTH = 27

        for i in 0...HIGHT {
          for j in 0...WIDTH {
            //create the path
            let plusPath = UIBezierPath()
            
            //set the path's line width to the height of the stroke
            plusPath.lineWidth = Constants.plusLineWidth
            
            //move the initial point of the path to the start of the horizontal stroke
            plusPath.move(to: CGPoint(
              x: CGFloat(j * 10),
              y: CGFloat(i * 10) + Constants.plusLineWidth / 2
            ))
            
            //add a point to the path at the end of the stroke
            plusPath.addLine(to: CGPoint(
              x: CGFloat((j * 10) + 10),
              y: CGFloat(i * 10) + Constants.plusLineWidth / 2
            ))
            
            //set the stroke color
            let index: [NSNumber] = [0 as NSNumber, i as NSNumber, j as NSNumber]
            UIColor(white: CGFloat(truncating: out.output[index]), alpha: CGFloat(1)).setStroke()
            
            //draw the stroke
            plusPath.stroke()
          }
          
        }
        
      }
        

}
