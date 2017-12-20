//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Kiss Levente on 2017. 08. 22..
//  Copyright © 2017. Kiss Levente. All rights reserved.
//

import Foundation


struct CalculatorBrain{
    private var currentNumber : Double?
    
    
    private var accumulator :(number : Double?,description : (String,String)?)
    
    var result : Double? {
        get{
            return accumulator.number
        }
    }
    var descrpiton : String? {
        get{
            if let result = accumulator.description{
                return result.0 + result.1
            }
            return nil
        }
    }
    
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double,Double)->Double)
        case equals
        case clear
    }
    
    private var operations :[String:Operation] = [
        "e" : Operation.constant(M_E),
        "π" : Operation.constant(Double.pi),
        "√" : Operation.unaryOperation({sqrt($0)}),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "🔄" : Operation.unaryOperation({-1 * $0}),
        "*" : Operation.binaryOperation({$0*$1}),
        "+" : Operation.binaryOperation({$0+$1}),
        "-" : Operation.binaryOperation({$0-$1}),
        "/" : Operation.binaryOperation({$0/$1}),
        "⁒" : Operation.binaryOperation({$0.truncatingRemainder(dividingBy: $1)}),
        "=" : Operation.equals,
        "C" : Operation.clear
    ]
    mutating func setOpreand(_ operand:Double){
        if let previosOperations = accumulator.description{
            accumulator = (operand,(previosOperations.0,"..."))
        }
        else{
            accumulator = (operand,(String(operand),""))
        }
        
    }
    
    mutating func performOperation(_ symbol:String){
        if let operation = operations[symbol] {
            switch operation {
                
            case .constant(let value):
                if let previosOperations = accumulator.description{
                    accumulator = (value,(previosOperations.0+symbol,""))
                }
               
                // performPendingBinaryOperation()
                
            case .unaryOperation(let function):
                if let number = accumulator.number{
                    if resultIsPending{
                        accumulator = (function(number),(accumulator.description!.0 + symbol + "(" + String(number) + ")" ,"="))
                    }
                    else{
                        if let previusResult = accumulator.description{
                            accumulator = (function(number),(symbol + "(" + previusResult.0 + ")" ,"="))
                        }
                        else{
                            accumulator = (function(number),(symbol + "(" + String(number) + ")" ,"="))
                        }
                        
                    }
                    
                }
//                if resultIsPending{
//                    accumulator = (function(accumulator.number!),"\(accumulator.description!)\(symbol)\(accumulator.number!)")
//                }
//                else{
//                    accumulator = (function(accumulator.number!),"\(symbol)(\(accumulator.description!))")
//                }
                
            case .binaryOperation(let function):
                if pendingBinaryOperation != nil {
                    accumulator = (accumulator.number,(accumulator.description!.0 + symbol,"..."))
                }
                else{
                    pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator.number!)
                    accumulator = (nil,(accumulator.description!.0 + symbol,"..."))
                    resultIsPending = true
                }
                
            case .equals:
                performPendingBinaryOperation()
                
            case .clear:
                accumulator = (0,nil)
                pendingBinaryOperation = nil
                resultIsPending = false
            }
        }
        
        
    }
    
    private var resultIsPending : Bool = false
    
    private var pendingBinaryOperation : PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        let operation : (Double,Double)->Double
        var firstOperand: Double
        
        
        func performOperation(with secondOperand:Double)->Double{
            return operation(firstOperand,secondOperand)
        }
        
    }
    
    private mutating func performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator.number != nil{
            accumulator = (pendingBinaryOperation!.performOperation(with: accumulator.number!),(accumulator.description!.0+String(accumulator.number!),"="))
            pendingBinaryOperation = nil
            resultIsPending = false
        }
    }
    
    
    
    
 
    
}

