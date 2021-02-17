//
//  Unary.swift
//  Calculator
//
//  Created by zb-nju on 2020/10/24.
//

import Foundation
class Unary{
    var deg:Bool = false
    
    func setDeg(){
        deg = !deg
    }
    
    func getDeg() -> Bool{
        return deg
    }
    
    func calculate(_ op:Operator, _ number:Double) -> Double{
        var ans = 0.0
        switch op {
        case .neg:
            ans = -number
        case .percentage:
            ans = number / 100
        case .pow2:
            ans = pow(number,2)
        case .pow3:
            ans = pow(number,3)
        case .exp:
            ans = exp(number)
        case .tenPow:
            ans = pow(10, number)
        case .reciprocal:
            ans = 1/number
        case .squareRoot:
            ans = sqrt(number)
        case .cubeRoot:
            ans = cbrt(number)
        case .ln:
            ans = log(number)
        case .log_10:
            ans = log10(number)
        case .fac:
            ans = myFac(Int(number))
        case .sin:
            ans = varyForDeg(sin, number)
        case .cos:
            ans = varyForDeg(cos, number)
        case .tan:
            ans = varyForDeg(tan, number)
        case .sinh:
            ans = sinh(number)
        case .cosh:
            ans = cosh(number)
        case .tanh:
            ans = tanh(number)
        default:
            assert(false)
        }
        return ans
    }
    
    func myFac(_ n:Int) -> Double{
        var arr:[Int] = []
        for i in 1...n{
            arr.append(i)
        }
        return Double(arr.reduce(1){$0*$1})
    }
    
    func varyForDeg(_ function:(Double)->Double,_ number:Double) -> Double{
        if deg{
            return function(number)
        }
        else{
            return function(number * Double.pi / 180.0)
        }
    }
}
