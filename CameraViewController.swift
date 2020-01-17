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

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet var viewCamera: UIView!
    
    @IBOutlet var outputLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //실시간 스트림 기반의 어떤 동작을 수행할때마다 사용된다.
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        //캡쳐할 디바이스 찾기, 기기에 세션 연결
        //AVCaptureDeviceInput인 입력은 카메라로 보고 있는 것이고 AVCaptureVideoDataOutput인 출력은 보여지는 비디오이다.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
       
        //비디오 미리보기
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = viewCamera.frame
        
        //초기화 될 때, DataOutput생성하고 setSampleBufferDelegate라는 델리게이트 메소드에 넣어준다.
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    //세션이 실행되면 델리게이트 메소드인 아래 문장이 호출된다.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

        // 모델 생성하고 SecondView랑 똑같은 로직
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model)
        { (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation]
                else { return }

            guard let firstObservation = results.first else { return}

            DispatchQueue.main.async { [weak self] in
                self?.outputLabel.text = "\(firstObservation.identifier) : \(Int(firstObservation.confidence * 100))%"
            }
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
