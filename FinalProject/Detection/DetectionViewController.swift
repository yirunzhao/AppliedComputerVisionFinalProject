//
//  DetectionViewController.swift
//  FinalProject
//
//  Created by Yirun Zhao on 2020/5/5.
//  Copyright © 2020 Yirun Zhao. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

class DetectionViewController: UIViewController {

    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!
    // define the model
    let model = YOLOv3()
    
    // vision
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    var isInferencing = false
    // AV
    var videoCapture: VideoCapture!
    let semaphore = DispatchSemaphore(value: 1)
    var lastExecution = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initModel()
        initCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    func initModel(){
        if let visionModel = try? VNCoreMLModel(for: model.model){
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError("创建model失败")
        }
    }
    
    func initCamera(){
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .hd4K3840x2160) {
            success in if success{
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }

                // start caputering video
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.resizePreviewLayer()
    }
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}


extension DetectionViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        if !self.isInferencing, let pixelBuffer = pixelBuffer {
            self.isInferencing = true
            
            self.predictUsingVision(pixelBUffer: pixelBuffer)
        }
    }
}

extension DetectionViewController {
    func predictUsingVision(pixelBUffer: CVPixelBuffer) {
        guard let request = request else {fatalError("97 line")}
        self.semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBUffer)
        try? handler.perform([request])
//        print("执行到这里了101")
    }
    
    
    func visionRequestDidComplete(request: VNRequest, error: Error?){
        if let predictions = request.results as? [VNRecognizedObjectObservation] {
//            print("我执行到这里了")
            DispatchQueue.main.async {
                self.boxesView.predictedObjects = predictions
                
                self.isInferencing = false
            }
        }
        self.semaphore.signal()
    }
}

//class MovingAverageFilter
