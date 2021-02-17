//
//  Memory.swift
//  
//
//  Created by zb-nju on 2020/10/24.
//

import Foundation
class Memory {
    var memory:Double = 0.0
    
    func calculate(_ op:Operator,_ number:inout Double){
        switch op {
        case .mc:
            memory = 0.0
        case .mp:
            memory += number
        case .mm:
            memory -= number
        case .mr:
            number = memory
        default:
            assert(false)
        }
    }
    
    func reset(){
        memory = 0.0
    }
}
