//
//  FlowerViewController.swift
//  FinalProject
//
//  Created by Yirun Zhao on 2020/5/5.
//  Copyright © 2020 Yirun Zhao. All rights reserved.
//

import UIKit
import CoreML

class FlowerViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flowerClass: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    
    var model: FlowerNet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        model = FlowerNet()
    }

    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true)
    }
}

extension FlowerViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("cancel")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        picker.dismiss(animated: true)
        flowerClass.text = "Analyzing Image ..."
        guard let image = info[.originalImage] as? UIImage else{
            return
        }
//        print("运行到这")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 229, height: 229), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 229, height: 229))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3

        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        imageView.image = newImage

        guard let prediction = try? model.prediction(image: pixelBuffer!) else {
            return
        }

        flowerClass.text = "Flower is: \(prediction.classLabel)"
        print(prediction.classLabel)
        print(prediction.classLabelProbs[prediction.classLabel]!)
        accuracy.text = "Accuracy: \(prediction.classLabelProbs[prediction.classLabel]!)"
    }
}
