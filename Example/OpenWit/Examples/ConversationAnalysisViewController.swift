//
//  ConversationAnalysisViewController.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import OpenWit
import ObjectMapper


/// A view controller to demonstrate the use of Wit message analysis Api
/*
 func conversationMessage(_ message: String,
 sessionId: String,
 context: Mappable? = nil,
 completion: @escaping (_ result: OpenWitResult<OpenWitConverseModel, OpenWitError>) -> ())
 
 func conversationAction(_ action: Mappable,
 sessionId: String,
 context: Mappable? = nil,
 completion: @escaping (_ result: OpenWitResult<OpenWitConverseModel, OpenWitError>) -> ())
 
 */
class ConversationAnalysisViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet private var textField : UITextField!
    @IBOutlet private var textView : UITextView!
    
    private let conversationManager = OpenWitConversationManager()
    private var context = OpenWitContext(referenceTime: Date().referenceTime)
    
    //MARK: @IBAction methods
    
    @IBAction func startConversation(_ sender: Any) {
        textView.text = ""
        guard let message = textField.text else {
            return
        }
        textField.text = ""
        printResult("You: \(message)")
        conversationManager.startConversation(message,
                                              context: context) { [unowned self] (response) in
                                                self.printResult("WIT: \(response)")
        }
    }
    
    @IBAction func answer(_ sender: Any) {
        guard let message = textField.text else {
            return
        }
        textField.text = ""
        printResult("You: " + message)
        conversationManager.converse(message,
                                     context: context) { [unowned self] (response) in
                                        self.printResult("WIT: \(response)")
        }
    }
    
    //MARK: private methods
    
    
    
    
    //MARK: private utils
    
    private func printResult(_ str: String) {
        textView.text = textView.text + "\n" + str
    }
}
