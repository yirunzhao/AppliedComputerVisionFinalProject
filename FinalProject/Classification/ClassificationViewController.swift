//
//  ClassificationViewController.swift
//  FinalProject
//
//  Created by Yirun Zhao on 2020/5/3.
//  Copyright © 2020 Yirun Zhao. All rights reserved.
//

import UIKit
import CoreML

class ClassificationViewController: UIViewController, UINavigationControllerDelegate{

    // connect the label and ImageView
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var objectClass: UILabel!
    @IBOutlet weak var detectAccuracy: UILabel!
    
    // declare model
    var model: Resnet50!
    override func viewWillAppear(_ animated: Bool) {
        model = Resnet50()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func useCamera(_ sender: Any) {
        // 如果无法使用camera，就返回
        // if we can't use camera, just return, we can also use guard to implement this
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        // 实例化ImagePicker
        // make instance of UIImagePickerController
        let cameraPicker = UIImagePickerController()
        // register delegate
        cameraPicker.delegate = self
        // register source type
        cameraPicker.sourceType = .camera
        // don't allow edit
        cameraPicker.allowsEditing = false
        
        // present the camera
        present(cameraPicker, animated: true)
    }
    
    @IBAction func useLibrary(_ sender: Any) {
        // make instance of picker
        let picker = UIImagePickerController()
        // don't allow edit
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        // present
        present(picker, animated: true)
        
        
    }
}

// extend controller, implement UIImagePickerControllerDelegate
extension ClassificationViewController: UIImagePickerControllerDelegate {
    // _ before parameter means when call the function, we can ignore parameter's name
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("cancel")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        picker.dismiss(animated: true)
        objectClass.text = "Analyzing Image ..."
        guard let image = info[.originalImage] as? UIImage else{
            return
        }
        print("here")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
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

        objectClass.text = "Class: \(prediction.classLabel)"
        print(prediction.classLabelProbs[prediction.classLabel]!)
        detectAccuracy.text = "Accuracy: \(prediction.classLabelProbs[prediction.classLabel]!)"
    }
}
