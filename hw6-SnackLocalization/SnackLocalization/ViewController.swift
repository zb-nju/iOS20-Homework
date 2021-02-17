//
//  ViewController.swift
//  SnackLocalization
//
//  Created by zb-nju on 2020/12/3.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var Frame: UIImageView!
    @IBOutlet weak var Label: UILabel!
    let class_name = [
        "apple",
        "banana",
        "cake",
        "candy",
        "carrot",
        "cookie",
        "doughnut",
        "grape",
        "hot dog",
        "ice cream",
        "juice",
        "muffin",
        "orange",
        "pineapple",
        "popcorn",
        "pretzel",
        "salad",
        "strawberry",
        "waffle",
        "watermelon",
    ]

    // for video capturing
    var videoCapturer: VideoCapture!
    let semphore = DispatchSemaphore(value: ViewController.maxInflightBuffer)
    var inflightBuffer = 0
    static let maxInflightBuffer = 2
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do{
            let classifier = try snack_detection(configuration: MLModelConfiguration())
            
            let model = try VNCoreMLModel(for: classifier.model)
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request,error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
            
            
        } catch {
            fatalError("Failed to create request")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpCamera()
    }

    func setUpCamera() {
        self.videoCapturer = VideoCapture()
        self.videoCapturer.delegate = self
        
        videoCapturer.frameInterval = 1
        videoCapturer.setUp(sessionPreset: .high, completion: {
            success in
            if success {
                if self.videoCapturer.previewLayer != nil {
                    self.view.layer.addSublayer(self.videoCapturer.previewLayer)
                    self.videoCapturer.previewLayer.frame = self.view.layer.frame // 添加视图的捕捉层
                    self.videoCapturer.previewLayer.addSublayer(self.Label.layer) // 添加检测标识
                    self.videoCapturer.previewLayer.addSublayer(self.Frame.layer) // 添加检测框
                    self.videoCapturer.start()
                }
            }
            else {
                print("Video capturer set up failed")
            }
        })
    }}

extension ViewController: VideoCaptureDelegate {
    func videoCapture(capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        self.classify(sampleBuffer: sampleBuffer)
    }
}

extension ViewController {
    func classify(sampleBuffer: CMSampleBuffer) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            semphore.wait()
            inflightBuffer += 1
            if inflightBuffer >= ViewController.maxInflightBuffer {
                inflightBuffer = 0
            }
            DispatchQueue.main.async {
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
                do {
                    try handler.perform([self.classificationRequest])
                } catch {
                    print("Failed to perform classification: \(error)")
                }
                self.semphore.signal()
            }
            
        } else {
            print("Create pixel buffer failed")
        }
    }
}

extension ViewController {
    func processObservations(for request: VNRequest, error: Error?) {
        if let results = request.results as? [VNCoreMLFeatureValueObservation] {
            if results.isEmpty {
                self.enableFrame(false)
                self.enableLabel(false)
            } else {
                let first = results[0]
                let seconde = results[1]
                let class_values = first.featureValue.multiArrayValue!
                let rect_values = seconde.featureValue.multiArrayValue!
                
                let n = self.class_name.count
                var classes = [Float](repeating: 0, count: n)
                for c in 0..<n{
                    classes[c] = Float(truncating: class_values[c])
                }
                let max_idx = classes.firstIndex(of: classes.max()!)!
                
                let width = self.videoCapturer.previewLayer.frame.width
                let height = self.videoCapturer.previewLayer.frame.height
                
                let x_min = CGFloat(truncating: rect_values[0]) * width
                let x_max = CGFloat(truncating: rect_values[1]) * width
                let y_min = CGFloat(truncating: rect_values[2]) * height
                let y_max = CGFloat(truncating: rect_values[3]) * height
                
                let frame_rect = CGRect(x: x_min, y: y_min, width: x_max - x_min, height: y_max - y_min)
                let label_rect = CGRect(x: x_min, y: y_min + CGFloat(-20), width: CGFloat(200), height: CGFloat(20))
                enableLabel(true)
                enableFrame(true)
                
                DispatchQueue.main.async {
                    self.Frame.layer.frame = frame_rect
                    self.Label.text = self.class_name[max_idx]
                    self.Label.layer.frame = label_rect
                }
            }
        } else if let error = error {
            self.Label.text = "Error: \(error.localizedDescription)"
        } else {
            self.Label.text = "???"
        }
    }
    
    func enableFrame(_ enabled:Bool){
        self.Frame.layer.borderWidth = 8
        if(enabled){
            Frame.layer.borderColor = #colorLiteral(red:1, green:1, blue:1, alpha:1)
        }
        else{
            Frame.layer.borderColor = #colorLiteral(red:0, green:0, blue:0, alpha:0)
        }
    }
    
    func enableLabel(_ enabled:Bool){
        if(enabled){
            Label.textColor = #colorLiteral(red:1, green:1, blue:1, alpha:1)
        }
        else{
            Label.textColor = #colorLiteral(red:0, green:0, blue:0, alpha:0)
        }
    }
    
}
