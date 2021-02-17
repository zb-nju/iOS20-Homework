//
//  Binary.swift
//  Calculator
//
//  Created by zb-nju on 2020/10/24.
//

import Foundation
class Binary{
    var postFix:[Any] = []
    var opStack:Stack<Operator> = Stack()
    var numStack:Stack<Double> = Stack()
    
    init(){
        opStack.push(.eq)
    }
    
    func appendOp(_ op:Operator){
        while !opStack.isEmpty(){
            if(isp(opStack.peek()!)<icp(op)){
                opStack.push(op)
                break
            }
            else if(isp(opStack.peek()!)>icp(op)){
                postFix.append(opStack.pop()!)
            }
            else{
                let _ = opStack.pop()
                break
            }
        }
//
//        switch op {
//        case .rightP:
//            var e:Operator? = opStack.pop()
//            while e != .leftP{
//                if e == nil{
//                    return false
//                }
//                postFix.append(e!)
//                e = opStack.pop()
//            }
//        case .plus, .minus:
//            if opStack.isEmpty(){
//                opStack.push(op)
//            }
//            else{
//                var e:Operator!
//                repeat{
//                    e = opStack.pop()
//                    if e == .leftP {
//                        opStack.push(op)
//                    }
//                    else{
//                        postFix.append(e!)
//                    }
//                }while !opStack.isEmpty() && e != .leftP
//            }
//        case .multiply, .div, .leftP:
//            opStack.push(op)
//        default:
//            return false
//        }
    }
    
    func isp(_ op:Operator) -> Int{
        switch op {
        case .leftP:
            return 1
        case .powy, .yroot, .ee:
            return 7
        case .multiply, .div:
            return 5
        case .plus, .minus:
            return 3
        case .rightP:
            return 8
        default:
            return 0
        }
    }
    
    func icp(_ op:Operator) -> Int{
        switch op {
        case .leftP:
            return 8
        case .powy, .yroot, .ee:
            return 6
        case .multiply, .div:
            return 4
        case .plus, .minus:
            return 2
        case .rightP:
            return 1
        default:
            return 0
        }
    }
    
    func appendNum(_ number:Double){
        postFix.append(number)
    }
    
    func reset(){
        postFix.removeAll()
        opStack.clear()
        numStack.clear()
        opStack.push(.eq)
    }
    
    func calculate() -> (ans:Double,err:Bool){
        for x in postFix{
            if x is Double{
                numStack.push(x as! Double)
            }
            else{
                switch x as! Operator {
                case .plus:
                    if !varyForOp(+){
                        return (0.0,true)
                    }
                case .minus:
                    if !varyForOp(-){
                        return (0.0,true)
                    }
                case .multiply:
                    if !varyForOp(*){
                        return (0.0,true)
                    }
                case .powy:
                    if !varyForOp(pow){
                        return (0.0,true)
                    }
                case .yroot:
                    if !varyForOp({pow($0,1/$1)}){
                        return (0.0,true)
                    }
                case .ee:
                    if !varyForOp({$1 * pow(10,$0)}){
                        return (0.0,true)
                    }
                case .div:
                    if let a = numStack.pop(){
                        if let b = numStack.pop(){
                            if a != 0{
                                numStack.push(b/a)
                                break
                            }
                        }
                    }
                    return (0.0,true)
                default:
                    return (0.0,true)
                }
            }
        }
        if numStack.count == 1{
            return (numStack.peek()!,false)
        }
        else{
            return (0.0,true)
        }
    }
    
    func varyForOp(_ function:(Double,Double)->Double) -> Bool{
        if let a = numStack.pop(){
            if let b = numStack.pop(){
                numStack.push(function(a,b))
                return true
            }
        }
        return false
    }
}

struct Stack<T> {
    var elements:[T] = []
    var count:Int{
        return elements.count
    }
    
    mutating func push(_ element:T){
        elements.append(element)
    }
    
    mutating func pop() -> T?{
        return elements.popLast()
    }
    
    func peek() -> T?{
        return elements.last
    }
    
    mutating func clear(){
        elements.removeAll()
    }
    
    func isEmpty() -> Bool {
        return elements.isEmpty
    }
}
