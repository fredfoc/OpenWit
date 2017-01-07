//
//  OpenWitConversationManager.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import OpenWit
import ObjectMapper



/// Your logic to analyse Wit answers could go there
class OpenWitConversationManager {
    typealias ConversationCompletion = ((String) -> ())?

    private var converseSessionId = "1234"
    private var nextConverseType = OpenWitConverseType.unknwon
    
    func startConversation(_ message: String? = nil, context: Mappable? = nil, completion: ConversationCompletion = nil) {
        converseSessionId = String.randomString(length: 10)
        if let message = message {
            converse(message, context: context, completion: completion)
        }        
    }
    
    /// this will analyse the conversation (returns of Wit Api)
    ///
    /// - Parameter context: an optional context
    func converse(_ message: String, context: Mappable? = nil, completion: ConversationCompletion = nil) {
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
                                                    self.addShopItem(converse: converse, context: context, completion: completion)
                                                case "createList":
                                                    self.createList(converse: converse, context: context, completion: completion)
                                                default:
                                                    break
                                                }
                                            }
                                            
                                            
                                        case .msg:
                                            message = converse.msg!
                                        case .merge:
                                            message = "some merge"
                                        case .stop:
                                            message = "Merci (Fin de la conversation)"
                                        case .unknwon:
                                            message = "Oupss..."
                                        }
                                        if let message = message {
                                            completion?(message)
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
    private func createList(converse: OpenWitConverseModel, context: Mappable? = nil, completion: ConversationCompletion){
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
                                                            message = "Merci (Fin de la conversation)"
                                                        case .unknwon:
                                                            message = "Oupss..."
                                                        }
                                                        if let message = message {
                                                            completion?(message)
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
    private func addShopItem(converse: OpenWitConverseModel, context: Mappable? = nil, completion: ConversationCompletion){
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
                                                            self.addShopItem(converse: converse, context: context, completion: completion)
                                                        case .msg:
                                                            message = converse.msg!
                                                        case .merge:
                                                            message = "some merge"
                                                        case .stop:
                                                            message = "Merci (Fin de la conversation)"
                                                        case .unknwon:
                                                            message = "Oupss..."
                                                        }
                                                        if let message = message {
                                                            completion?(message)
                                                        }
                                                    case .failure(let error):
                                                        print(error)
                                                    }
        }
    }
}
