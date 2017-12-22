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
    
    var resultIsPending : Bool = false
  
    
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
    
    //private var variables : [String:Double]
    
   
    mutating func setOpreand(_ operand:Double){
        if let previosOperations = accumulator.description{
            accumulator = (operand,(previosOperations.0,String(operand)))
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
                    accumulator = (value,(previosOperations.0,symbol))
                }
                else{
                    accumulator=(value,(symbol,""))
                    
                }
               
                // performPendingBinaryOperation()
                
            case .unaryOperation(let function):
                if let number = accumulator.number{
                    if resultIsPending{
                        accumulator = (function(number),(accumulator.description!.0 + symbol + "(" + String(accumulator.description!.1) + ")" ,""))
                    }
                    else{
                        if let previusResult = accumulator.description{
                            accumulator = (function(number),(symbol + "(" + previusResult.0 + ")",""))
                        }
                        else{
                            accumulator = (function(number),(symbol + "(" + String(number) + ")",""))
                        }

                    }

                }
                
            case .binaryOperation(let function):
                if pendingBinaryOperation != nil {
                    accumulator = (accumulator.number,accumulator.description!)
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator.number!)
                    accumulator = (accumulator.number,(accumulator.description!.0 + symbol,accumulator.description!.1))
                    resultIsPending = true
                    
                }
                else{
                    pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator.number!)
                    accumulator = (nil,(accumulator.description!.0+symbol,accumulator.description!.1))
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
            accumulator = (pendingBinaryOperation!.performOperation(with: accumulator.number!),(accumulator.description!.0+accumulator.description!.1,""))
            pendingBinaryOperation = nil
            resultIsPending = false
        }
    }
}

struct Inputs {
    private enum Symbols{
        case variable(String)
        case number(Double)
        case operation(String)
    }
    
    private var variables:[String:Double]?
    
    private var inData:[Symbols]?
    
    mutating private func setIndata(data:Symbols){
        if inData != nil{
            inData?.append(data)
        }
        else{
            inData = [data]
        }
    }
    
    mutating func storeOpreand(_ operand:Double){
        setIndata(data: Symbols.number(operand))
    }
    
    mutating func storeOperand(variable named: String){
        setIndata(data: Symbols.variable(named))
    }
    
    mutating func storeOperation(_ operation:String){
        setIndata(data: Symbols.operation(operation))
    }
    
    
    
    
    
    
}

