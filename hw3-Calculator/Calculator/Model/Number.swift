//
//  Number.swift
//  Calculator
//
//  Created by zb-nju on 2020/10/24.
//

import Foundation
class Number{
    var hasDot:Bool = false
    var number:String = ""
    var value:Double?{
        return Double(number)
    }
    
    func append(_ num:Operator) -> Bool{
        switch num {
        case .one:
            number += "1"
        case .two:
            number += "2"
        case .three:
            number += "3"
        case .four:
            number += "4"
        case .five:
            number += "5"
        case .six:
            number += "6"
        case .seven:
            number += "7"
        case .eight:
            number += "8"
        case .nine:
            number += "9"
        case .zero:
            number += "0"
        case .dot:
            if !hasDot{
                number += "."
                hasDot = true
            }
            else{
                return true
            }
        default:
            assert(false)
        }
        return false
    }
    
    func reset(){
        number = ""
        hasDot = false
    }
}
