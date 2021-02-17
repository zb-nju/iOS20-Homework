//
//  WorkFlowContentViewController.swift
//  NJUNews
//
//  Created by nju on 2020/12/28.
//

import UIKit
import WebKit

class WorkFlowContentViewController: UIViewController {
    let webView = WKWebView()
    var news : News?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view = webView
        
        if let news = news{
            loadURL(news.URL)
        }
    }
    
    func loadURL(_ loadingURL : String){
        if let url = URL(string: loadingURL){
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
