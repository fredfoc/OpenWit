//
//  CustomConverseModels.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import OpenWit
import ObjectMapper

/// a custom enity defined as an answer
struct AddShopItemAnswerModel: Mappable {
    
    var shopListAlone: String?
    var shopItemAlone: String?
    var missingAll: Bool?
    var allOk: String?
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        shopListAlone          <- map["shopListAlone"]
        shopItemAlone                <- map["shopItemAlone"]
        missingAll               <- map["missingAll"]
        allOk           <- map["allOk"]
    }
    
    init(allOk: String?, shopListAlone: String?, shopItemAlone: String?, missingAll: Bool?) {
        self.allOk = allOk
        self.shopListAlone = shopListAlone
        self.shopItemAlone = shopItemAlone
        self.missingAll = missingAll
    }
}

struct CreateListAnswerModel: Mappable {
    
    var listName: String?
    var missingListName: String?
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        missingListName          <- map["missingListName"]
        listName                <- map["listName"]
    }
    
    init(listName: String?, missingListName: String?) {
        self.listName = listName
        self.missingListName = missingListName
    }
}
