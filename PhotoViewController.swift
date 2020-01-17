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
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
   
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model)
        { (finishedReq, err) in
            
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
