//
//  ViewController.swift
//  GestureClassifier
//
//  Created by zb-nju on 2020/12/20.
//

import UIKit
import CoreML
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    static let samplesPerSecond = 25.0
    static let numberOfFeatures = 6
    static let windowSize = 20
    static let windowOffset = 5
    static let numberOfWindows = windowSize / windowOffset
    static let bufferSize = windowSize + windowOffset * (numberOfWindows - 1)
    static let samplesSizeAsBytes = numberOfFeatures * MemoryLayout<Double>.stride
    static let windowOffsetAsBytes = windowOffset * samplesSizeAsBytes
    static let windowSizeAsBytes = windowSize * samplesSizeAsBytes
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let actions = ["chop it", "shake it", "drive it"]
    
    var bufferIndex = 0
    var isDataAvailable = false
    var output: GestureClassifierOutput!
    var isPlaying = false
    var score = 0
    var frameCount = 0
    var timer = 3
    var isTimeOut = false
    var action = ""
    
    static private func makeMLMultiArray(numberOfSamples: Int) -> MLMultiArray? {
        try? MLMultiArray(
            shape: [1, numberOfSamples, numberOfFeatures] as [NSNumber],
            dataType: .double
        )
    }
    
    let model: GestureClassifier = {
        do {
            return try GestureClassifier(configuration: MLModelConfiguration())
        } catch {
            fatalError("Fail to create model")
        }
    }()
    let modelInput = makeMLMultiArray(numberOfSamples: windowSize)!
    let dataBuffer = makeMLMultiArray(numberOfSamples: bufferSize)!
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        enableMotionUpdate()
    }
    
    func addToBuffer(_ x1: Int, _ x2: Int, _ data: Double) {
        dataBuffer[[0, x1, x2] as [NSNumber]] = NSNumber(value: data)
    }
    
    func buffer(_ motionData: CMDeviceMotion) {
        for offset in [0, ViewController.windowSize] {
            let index = bufferIndex + offset
            if index >= ViewController.bufferSize {
                continue
            }
            addToBuffer(index, 0, motionData.rotationRate.x)
            addToBuffer(index, 1, motionData.rotationRate.y)
            addToBuffer(index, 2, motionData.rotationRate.z)
            addToBuffer(index, 3, motionData.userAcceleration.x)
            addToBuffer(index, 4, motionData.userAcceleration.y)
            addToBuffer(index, 5, motionData.userAcceleration.z)
        }
    }
    
    func process(_ data:CMDeviceMotion){
        self.buffer(data)
        self.bufferIndex = (self.bufferIndex + 1) % ViewController.windowSize
        if self.bufferIndex == 0 {
            self.isDataAvailable = true
        }
        self.predict()
        DispatchQueue.main.async {
            self.run()
        }
    }

    func enableMotionUpdate(){
        motionManager.deviceMotionUpdateInterval = 1 / ViewController.samplesPerSecond
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: queue,
            withHandler: { [weak self] motionData, error in
                guard let self = self, let motionData = motionData else {
                    let errorText = error?.localizedDescription ?? "Unknown"
                    print("Device motion update error: \(errorText)")
                    return
                }
                self.process(motionData)
            }
        )
    }
    
    func disableMotionUpdate(){
        motionManager.stopDeviceMotionUpdates()
    }
    
    func play(){
        let index = Int.random(in: 0..<3)
        action = actions[index]
        actionLabel.text = "Try to " + action
        timer = 3
        isTimeOut = false
    }
    
    func run(){
        if !isPlaying{
            return
        }
        
        frameCount = (frameCount + 1) % Int(ViewController.samplesPerSecond)
        if !isTimeOut, output.activity == action{
            frameCount = 0
            isTimeOut = false
            score += 1
            scoreLabel.text = String(score)
            play()
        }
        else if frameCount == 0{
            if !isTimeOut{
                if timer == 0{
                    isTimeOut = true
                    score -= 1
                    scoreLabel.text = String(score)
                }
                else{
                    timer -= 1
                }
            }
            else{
                play()
            }
        }
    }
    
    func predict(){
        if isDataAvailable && bufferIndex % ViewController.windowOffset == 0 && bufferIndex + ViewController.windowOffset <= ViewController.windowSize {
            let window = bufferIndex / ViewController.windowOffset
            memcpy(modelInput.dataPointer, dataBuffer.dataPointer.advanced(by: window * ViewController.windowOffsetAsBytes), ViewController.windowSizeAsBytes)
            
            var classifierInput: GestureClassifierInput? = nil
            if output == nil{
                classifierInput = GestureClassifierInput(features: modelInput)
            }
            else{
                classifierInput = GestureClassifierInput(features: modelInput, hiddenIn: output.hiddenOut, cellIn: output.cellOut)
            }
            
            output = try? model.prediction(input: classifierInput!)
            
            DispatchQueue.main.async {
                self.resultLabel.text = self.output.activity
                self.confidenceLabel.text = String(format: "%.1f%%",self.output.activityProbability[self.output.activity]! * 100)
            }
            
        }
    }
    
    @IBAction func StartAndStop(_ sender: Any) {
        if !isPlaying{
            isPlaying = true
            frameCount = 0
            score = 0
            scoreLabel.text = "0"
            startButton.setTitle("Stop", for: .normal)
            play()
        }
        else{
            isPlaying = false
            startButton.setTitle("Start", for: .normal)
            actionLabel.text = "Take a rest!"
            disableMotionUpdate()
        }
    }
}

