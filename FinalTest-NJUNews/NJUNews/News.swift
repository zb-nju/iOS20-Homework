//
//  News.swift
//  NJUNews
//
//  Created by nju on 2020/12/28.
//

import UIKit

class News: NSObject {
    //MARK: Properties
    
    var title: String
    var URL: String
    var date: String
    
    //MARK: Initialization
    init?(title: String, URL: String, date: String){
        guard !title.isEmpty else{
            return nil
        }
        
        guard !URL.isEmpty else {
            return nil
        }
        
        guard !date.isEmpty else{
            return nil
        }
        self.title = title
        self.URL = URL
        self.date = date
    }
    
}
