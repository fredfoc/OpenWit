//
//  CustomModels.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 Fred Fauquette. All rights reserved.
//

import Foundation
import OpenWit
import ObjectMapper

/// a custom entity defined in Wit
struct ShopItemEntity: Mappable, OpenWitGenericEntityModelProtocol {
    static var entityId = "shopItem"
    
    var suggested: Bool = false
    var confidence: Float?
    var type: String?
    var value: String?
    
    public init?(map: Map) {}
}

/// a custom entity defined in Wit
struct ShopListEntity: Mappable, OpenWitGenericEntityModelProtocol {
    static var entityId = "shopList"
    
    var suggested: Bool = false
    var confidence: Float?
    var type: String?
    var value: String?
    
    public init?(map: Map) {}
}



/// A context that can be set for any type of message or conversation.
/// See Wit documentation to interact with Context in Message/Conversation
struct OpenWitContext: Mappable {
    
    var timeZone: String?
    var referenceTime: String?
    
    static let localTimeZoneName = {
        return (NSTimeZone.local as NSTimeZone).name
    }()
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        referenceTime           <- map["reference_time"]
        timeZone                <- map["timezone"]
    }
    
    init(referenceTime: String?) {
        self.timeZone = OpenWitContext.localTimeZoneName
        self.referenceTime = referenceTime
    }
}
