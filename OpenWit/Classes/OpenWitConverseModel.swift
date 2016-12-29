//
//  OpenWitConverseModel.swift
//  OpenWit
//
//  Created by fauquette fred on 8/12/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import ObjectMapper


public enum OpenWitConverseType: String {
    case unknwon = "unknwon"
    case msg = "msg"
    case merge = "merge"
    case action = "action"
    case stop = "stop"
}

/// A Model to handle Wit Message Response
public struct OpenWitConverseModel: Mappable, EntitiesCompatible{
    
    public fileprivate(set) var type = OpenWitConverseType.unknwon
    public fileprivate(set) var confidence: Float?
    public fileprivate(set) var jsonEntities: [String: Any]?
    
    fileprivate var map: Map
    
    public init?(map: Map) {
        self.map = map
    }
    
    mutating public func mapping(map: Map) {
        self.map = map
        type           <- map[OpenWitJsonKey.type.rawValue]
        confidence     <- map[OpenWitJsonKey.confidence.rawValue]
        jsonEntities = map.JSON[OpenWitJsonKey.entities.rawValue] as? [String: Any]
    }
}

extension OpenWitConverseModel {
    public var msg: String? {
        return try? map.value(OpenWitConverseType.msg.rawValue)
    }
    public var action: String? {
        return try? map.value(OpenWitConverseType.action.rawValue)
    }
    public var quickreplies: [String]? {
        return try? map.value(OpenWitJsonKey.quickreplies.rawValue)
    }
}

extension OpenWitConverseModel: CustomStringConvertible {
    public var description: String {
        return
            "type: " + type.rawValue
                + "\naction: "
                + (action ?? "no action")
                + "\nentities: "
                + (jsonEntities?.description ?? "no entities")
                + "\nquickreplies: "
                + (quickreplies?.description ?? "no quickreply")
    }
}
