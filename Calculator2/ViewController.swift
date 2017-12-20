//
//  ViewController.swift
//  Calculator2
//
//  Created by Kiss Levente on 2017. 10. 29..
//  Copyright © 2017. Kiss Levente. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calculation : UILabel!
    
    @IBOutlet weak var screen: UILabel!

    var userInMiddleOfTyping = false
    
    @IBAction func touch(_ sender: UIButton) {
        if userInMiddleOfTyping{
            // We check first if the user hitted . and then if there isnt't any . in display if both are true we append . in other case if there is . in
            // display we append nothing and if hitted button wasn't . we append it
            screen.text! += sender.currentTitle! == "." ? !screen.text!.contains(".") ? sender.currentTitle! : "" : sender.currentTitle!
        }
        else{
            //We check if the hitted button is . In that case we write 0. to the screen because we don't want to have .1012
            screen.text! = sender.currentTitle! == "." ? "0\(sender.currentTitle!)": sender.currentTitle!
            userInMiddleOfTyping = true
        }
        
        
    }
    var displayValue : Double{
        set{
            screen.text! = String(newValue)
        }
        get{
            return Double(screen.text!)!
        }
    }
    
    var operations : String?{
        set{
            calculation.text = newValue
        }
        get{
            return screen.text
        }
    }
    
    private var brain = CalculatorBrain()
    

  
    @IBAction func perforOperation(_ sender: UIButton) {
        if userInMiddleOfTyping{
            brain.setOpreand(displayValue)
            userInMiddleOfTyping = false
        }
        if let matheMaticalOperation = sender.currentTitle{
            brain.performOperation(matheMaticalOperation)
            
        }
        if let brainResault = brain.result{
            displayValue = brainResault
        }
        if let displayValue = brain.descrpiton{
            operations = displayValue
        }
    }
    
}

