//
//  ViewController.swift
//  HelloWorld
//
//  Created by zb-nju on 2020/9/15.
//  Copyright © 2020 nju. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var myLabel: UILabel!
    
    @IBAction func changeLabel(){
        print("changeLabel被执行")
        myLabel.text = "你好！" + String(arc4random_uniform(10))
        
    }
    
    
    @IBAction func showAlert(){
        let alert = UIAlertController(title: "警告", message: "梓博，你太菜啦！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "朕知道了", style: .default, handler: nil))
        self.present(alert,animated: true,completion: nil)
    }
}

