//
//  MessageAnalysisViewController.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 Fred Fauquette. All rights reserved.
//

import UIKit
import OpenWit


/// A view controller to demonstrate the use of Wit message analysis Api
/*
 Just call 
 func message(_ message: String,
                 messageId: String? = nil,
                 threadId: String? = nil,
                 context: Mappable? = nil,
                 completion: @escaping (_ result: OpenWitResult<OpenWitMessageModel, OpenWitError>) -> ())
 */
class MessageAnalysisViewController:UIViewController {
    
    @IBOutlet var textFieldMessage : UITextField!
    @IBOutlet var textView : UITextView!
    
    @IBAction func testMessageButton(_ sender: Any) {
        guard let message = textFieldMessage.text else {
            return
        }
        OpenWit
            .sharedInstance
            .message(message,
                     messageId: nil,
                     threadId: nil) {[unowned self] result in
                        switch result {
                        case .success(let message):
                            /// Your logic should start here... :-)
                            /// intents are generic entities so they are built in
                            self.printResult(message.intents?.description ?? "no intent", clearResult: true)
                            /// shopItems are custom entities
                            self.printResult(message.shopItems?.description ?? "no shopItem")
                            /// shopLists are custom entities
                            self.printResult(message.shopLists?.description ?? "no shopList")
                        case .failure(let error):
                            print(error)
                        }
        }
    }

    
    private func printResult(_ str: String, clearResult: Bool = false) {
        textView.text = clearResult ? str : textView.text + "\n" + str
    }
}

extension MessageAnalysisViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
