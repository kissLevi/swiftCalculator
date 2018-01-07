//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Kiss Levente on 2017. 08. 22..
//  Copyright © 2017. Kiss Levente. All rights reserved.
//

import Foundation


struct CalculatorBrain{
    
    private enum InputTypes{
        case symbol(String)
        case number(Double)
        case variable(String)
    }
    
    private var inputs = [InputTypes]()
    
    var result : Double? {
        get{
            return evaluate().result
        }
    }
    var descrpiton : String? {
        get{
            let operations = evaluate().description
            if operations == ""{
                return nil
            }
            else{
                return operations
            }
        }
    }
    
    var resultIsPending : Bool {
        get{
            return evaluate().isPending
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
        inputs.append(InputTypes.number(operand))
    }
    
    mutating func setOperand(variable named: String){
        inputs.append(InputTypes.variable(named))
    }
    
    mutating func performOperation(_ symbol:String){
        switch inputs.last!{
        case .symbol(let value):
            if value == "C" || value == "=" || symbol == "C"{
                inputs.append(InputTypes.symbol(symbol))
            }
        default:
            inputs.append(InputTypes.symbol(symbol))
        }
        
        
    }
    
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String){
            
            func getNumber(_ from : InputTypes)->Double?{
                var number: Double?
                switch from{
                case .number(let value):
                    number = value
                
                default:
                    number = nil
                }
                return number
            }

            var result : Double?
            var isPending : Bool = true
            var description = [String]()
            var pendingBinaryOperation : PendingBinaryOperation?
            for currentIndex in 0...inputs.count-1{
                switch inputs[currentIndex]{
                case .number(let value):
                    if pendingBinaryOperation != nil{
                        result = pendingBinaryOperation!.performOperation(with: value)
                        pendingBinaryOperation = nil
                    }
                    description.append(String(value))
                case .symbol(let symbol):
                    if let operation = operations[symbol] {
                        switch operation {
                        case .constant(let value):
                           description.append(String(value))
                        case .unaryOperation(let function):
                            if 0 < currentIndex {
                                if let number = getNumber(inputs[currentIndex-1]){
                                    if result != nil{
                                        result! += function(number)
                                        description.removeLast()
                                    }
                                    else{
                                        result = function(number)
                                    }
                                    description.append( "\(symbol)(\(number))")
                                }
                            }
                        case .binaryOperation(let function):
                            if pendingBinaryOperation == nil && 0<currentIndex{
                                if result != nil{
                                    pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: result!)
                                }
                                else if let firstOperand = getNumber(inputs[currentIndex-1]){
                                    pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: firstOperand)
                                }
                            }
                            description.append(symbol)
                        case .equals:
                            isPending = false
                        case .clear:
                            pendingBinaryOperation = nil
                            result = 0
                            isPending = true
                            description.removeAll()
                        }
                    }
                case .variable(let value):
                    description.append(value)
                }
            }
            return (result,isPending,description.joined(separator: ""))
    }
    
  
    
    
    private var pendingBinaryOperation : PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        let operation : (Double,Double)->Double
        var firstOperand: Double
        
        
        func performOperation(with secondOperand:Double)->Double{
            return operation(firstOperand,secondOperand)
        }
        
    }
    
}

