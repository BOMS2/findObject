//
//  CameraViewController.swift
//  FindFingerprint
//
//  Created by 김삼복 on 15/06/2019.
//  Copyright © 2019 김삼복. All rights reserved.
//

import UIKit
import AVKit
import Vision

class PhotoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet var photoView: UIImageView!
    
    @IBOutlet var photoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoLabel.text = "Waiting..."
        
//        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
//
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
//        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
//        captureSession.addInput(input)
//
//        captureSession.startRunning()
        
        
        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = photoView.frame
//
//
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue"))
//        captureSession.addOutput(dataOutput)
        
        //        let request = VNCoreMLRequest(model: VNCoreMLModel, completionHandler: VNRequestCompletionHandler?)
        //        VNImageRequestHandler(cpImage: CGImage, options: [:].perfrom(requests: [VNRequest])
        
        
        
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        //print("Camera was able to capture a frame: ", Data())
        
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model)
        { (finishedReq, err) in
            // print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation]
                else { return }
            
            guard let firstObservation = results.first else { return}
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async { [weak self] in
                self?.photoLabel.text = "\(firstObservation.identifier) : \(Int(firstObservation.confidence * 100))%"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
