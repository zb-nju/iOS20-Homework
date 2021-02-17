//
//  ViewController.swift
//  Calculator
//
//  Created by zb-nju on 2020/10/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lastLineLabel: UILabel!
    @IBOutlet weak var ansLabel: UILabel!
    @IBOutlet weak var deg: UIButton!
    var model = Model();
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deg.setTitle(model.getDeg() ? "Deg" : "Rad", for: .normal)
    }
    @IBAction func solveTouched(_ sender: UIButton) {
        let op = Operator(rawValue: sender.tag)
        let result = model.calculate(op!)
        if result.err{
            ansLabel.text = "错误"
        }
        else{
            if result.ans.truncatingRemainder(dividingBy: 1) == 0{
                ansLabel.text = String(Int(result.ans))
            }
            else{
                ansLabel.text = String(result.ans)
            }
        }
        deg.setTitle(model.getDeg() ? "Deg" : "Rad", for: .normal) 
    }
    
}

