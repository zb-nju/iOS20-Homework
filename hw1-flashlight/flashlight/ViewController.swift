//
//  ViewController.swift
//  flashlight
//
//  Created by zb-nju on 2020/9/22.
//  Copyright © 2020 nju. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet var myview: UIView!
    @IBOutlet weak var onImage: UIImageView!
    @IBOutlet weak var offImage: UIImageView!
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var myLabel: UILabel!
    let device = AVCaptureDevice.default(for: AVMediaType.video)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mySwitch.setOn(false, animated: false)
        onImage.isHidden = true
        offImage.isHidden = false
        myButton.setTitle("off", for: .normal)
        myview.backgroundColor = UIColor.black
        myLabel.textColor = UIColor.white
        myLabel.text = "闪光灯已关闭"
        try? device?.lockForConfiguration()
        device?.torchMode = .off
        device?.unlockForConfiguration()
    }
	
    @IBAction func touchButton(_ sender: UIButton) {
        if sender.currentTitle == "on" {
            myview.backgroundColor = UIColor.black
            onImage.isHidden = true
            offImage.isHidden = false
            myLabel.textColor = UIColor.white
            sender.setTitle("off", for: .normal)
        }
        else{
            myview.backgroundColor = UIColor.white
            onImage.isHidden = false
            offImage.isHidden = true
            myLabel.textColor = UIColor.black
            sender.setTitle("on", for: .normal)
        }
    }
    
    @IBAction func myswitch(_ sender: UISwitch) {
        if (device?.isTorchAvailable) != nil{
            try? device?.lockForConfiguration()
            if sender.isOn {
                myLabel.text = "闪光灯已打开"
                device?.torchMode = .on
            }
            else{
                myLabel.text = "闪光灯已关闭"
                device?.torchMode = .off
            }
            device?.unlockForConfiguration()
        }
    }
}

