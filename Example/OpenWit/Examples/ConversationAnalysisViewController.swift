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
    
    
    //start with this to handle conversation
    private var converseSessionId = "1234"
    private var nextConverseType = OpenWitConverseType.unknwon
    
    //MARK: @IBAction methods
    
    @IBAction func startConversation(_ sender: Any) {
        textView.text = ""
        converseSessionId = String.randomString(length: 10)
        let context = OpenWitContext(referenceTime: Date().referenceTime)
        converse(context: context)
    }
    
    @IBAction func answer(_ sender: Any) {
        converse()
    }
    
    //MARK: private methods
    
    
    /// this will analyse the conversation (returns of Wit Api)
    ///
    /// - Parameter context: an optional context
    private func converse(context: Mappable? = nil) {
        guard let message = textField.text else {
            return
        }
        textField.text = ""
        printResult("You: " + message)
        OpenWit
            .sharedInstance
            .conversationMessage(message,
                                 sessionId: converseSessionId,
                                 context: context)  {[unowned self] result in
                                    switch result {
                                    case .success(let converse):
                                        /// Your logic should start here... :-)
                                        var message: String?
                                        self.nextConverseType = converse.type
                                        switch converse.type {
                                        case .action:
                                            if let action = converse.action {
                                                switch action {
                                                case "addShopItem":
                                                    self.addShopItem(converse: converse, context: context)
                                                case "createList":
                                                    self.createList(converse: converse, context: context)
                                                default:
                                                    break
                                                }
                                            }
                                            
                                            
                                        case .msg:
                                            message = converse.msg!
                                        case .merge:
                                            message = "some merge"
                                        case .stop:
                                            message = "end of conversation"
                                        case .unknwon:
                                            message = "oups something stange happened"
                                        }
                                        if let message = message {
                                            self.printResult("WIT: \(message)")
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
        }
    }
    
    
    
    /// In case we get a createList action from Wit
    ///
    /// - Parameters:
    ///   - converse: the return from Wit
    ///   - context: an optional context
    private func createList(converse: OpenWitConverseModel, context: Mappable? = nil){
        let createListAnswerModel: CreateListAnswerModel
        if let shopList = converse.shopList {
            createListAnswerModel = CreateListAnswerModel(listName: shopList.value, missingListName: nil)
        } else {
            createListAnswerModel = CreateListAnswerModel(listName: nil, missingListName: "something is missing here")
        }
        OpenWit.sharedInstance.conversationAction(createListAnswerModel,
                                                  sessionId: converseSessionId,
                                                  context: context) {[unowned self] result in
                                                    switch result {
                                                    case .success(let converse):
                                                        /// Your logic should start here... :-)
                                                        var message: String?
                                                        self.nextConverseType = converse.type
                                                        switch converse.type {
                                                        case .action:
                                                            print(converse)
                                                        case .msg:
                                                            message = converse.msg!
                                                        case .merge:
                                                            message = "some merge"
                                                        case .stop:
                                                            message = "end of conversation"
                                                        case .unknwon:
                                                            message = "oups something stange happened"
                                                        }
                                                        if let message = message {
                                                            self.printResult("WIT: \(message)")
                                                        }
                                                    case .failure(let error):
                                                        print(error)
                                                    }
        }
    }
    
    
    /// In case we get a addShopItem form Wit action from Wit
    ///
    /// - Parameters:
    ///   - converse: the return from Wit
    ///   - context: an optional context
    private func addShopItem(converse: OpenWitConverseModel, context: Mappable? = nil){
        let addShopItemAnswerModel: AddShopItemAnswerModel
        if let shopItem =  converse.shopItem, let shopList = converse.shopList {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: (shopItem.value ?? "strange product") +  " ajouté à " + (shopList.value ?? "strange list"),
                                                            shopListAlone: nil,
                                                            shopItemAlone: nil,
                                                            missingAll: nil)
        } else if let shopItem =  converse.shopItem {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: nil,
                                                            shopListAlone: nil,
                                                            shopItemAlone: shopItem.value,
                                                            missingAll: nil)
        } else if let shopList = converse.shopList {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: nil,
                                                            shopListAlone: shopList.value,
                                                            shopItemAlone: nil,
                                                            missingAll: nil)
        } else {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: nil,
                                                            shopListAlone: nil,
                                                            shopItemAlone: nil,
                                                            missingAll: true)
        }
        OpenWit.sharedInstance.conversationAction(addShopItemAnswerModel,
                                                  sessionId: converseSessionId,
                                                  context: context) {[unowned self] result in
                                                    switch result {
                                                    case .success(let converse):
                                                        /// Your logic should start here... :-)
                                                        var message: String?
                                                        self.nextConverseType = converse.type
                                                        switch converse.type {
                                                        case .action:
                                                            self.addShopItem(converse: converse, context: context)
                                                        case .msg:
                                                            message = converse.msg!
                                                        case .merge:
                                                            message = "some merge"
                                                        case .stop:
                                                            message = "end of conversation"
                                                        case .unknwon:
                                                            message = "oups something stange happened"
                                                        }
                                                        if let message = message {
                                                            self.printResult("WIT: \(message)")
                                                        }
                                                    case .failure(let error):
                                                        print(error)
                                                    }
        }
    }
    
    //MARK: private utils
    
    private func printResult(_ str: String, clearResult: Bool = false) {
        textView.text = clearResult ? str : textView.text + "\n" + str
    }
}
