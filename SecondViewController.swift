//
//  SecondViewController.swift
//  FindFingerprint
//
//  Created by 김삼복 on 15/06/2019.
//  Copyright © 2019 김삼복. All rights reserved.
//

import UIKit
import CoreML
import Vision

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var myPhoto: UIImageView!
    @IBOutlet var lblResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        detectImageContent()
    }
    
    func detectImageContent() {
        lblResult.text = "Thinking..."
        let mlmodel = Resnet50().model
        //모델 인스턴스 생성
        guard let model = try? VNCoreMLModel(for: mlmodel) else {
            fatalError("Failed to load model")
        }
        
        //vision request 생성
        //CoreML 요청하고 결과
        //VNClassificationObservation는 이미지분석 결과 확인
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }

            // 결과를 화면에 업데이트해줌
            // 정확도 나타내줌
            DispatchQueue.main.async { [weak self] in
                self?.lblResult.text = "\(topResult.identifier) with \(Int(topResult.confidence * 100))% confidence"
            }
        }
        
        guard let ciImage = CIImage(image: self.myPhoto.image!)
            else { fatalError("Cant create CIImage from UIImage") }
        
        // 백그라운드에서 이미지분석 실행
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            myPhoto.contentMode = .scaleAspectFit
            myPhoto.image = pickedImage
        }
        else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myPhoto.contentMode = .scaleAspectFit
            myPhoto.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        detectImageContent()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
