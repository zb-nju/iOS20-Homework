//
//  Model.swift
//  Calculator
//
//  Created by zb-nju on 2020/10/23.
//

import Foundation
class Model{
    var ret = 0.0
    var memory = Memory()
    var number = Number()
    var unary = Unary()
    var binary = Binary()
    
    func calculate(_ op:Operator) -> (ans:Double,err:Bool) {
        var hasError = false
        switch op {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .dot:
            hasError = number.append(op)
            ret = number.value ?? 0.0
        case .neg, .percentage, .pow2, .pow3, .exp, .tenPow, .reciprocal, .squareRoot, .cubeRoot, .ln, .log_10, .fac, .sin, .cos, .tan, .sinh, .cosh, .tanh:
            ret = unary.calculate(op, ret)
        case .mc, .mp, .mm, .mr:
            memory.calculate(op, &ret)
        case .powy, .yroot, .ee, .multiply, .div, .plus, .minus, .rightP, .leftP:
            if ret != 0{
                binary.appendNum(ret)
                ret = 0.0
            }
            number.reset()
            binary.appendOp(op)
        case .eq:
            if ret != 0{
                binary.appendNum(ret)
                ret = 0.0
            }
            binary.appendOp(op)
            (ret,hasError) = binary.calculate()
            number.reset()
            binary.reset()
            return (ret,hasError)
        case .ac:
            memory.reset()
            number.reset()
            binary.reset()
            ret = 0.0
        case .pi:
            ret = Double.pi
        case .rand:
            ret = Double.random(in: 0...1)
        case .shift:
            break
        case .e:
            ret = M_E
        case .rad:
            unary.setDeg()
        }
        return (ret, hasError)
    }
    
    func getDeg() -> Bool{
        return unary.getDeg()
    }
}


