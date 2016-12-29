//
//  OpenWitMessageModel.swift
//  OpenWit
//
//  Created by fauquette fred on 22/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol EntitiesCompatible {
    var jsonEntities: [String: Any]? {get}
    func getEntitities<U: Mappable>(for entityId: String) throws -> [U]
    func getGenericEntities<U: Mappable>(for genericEntityId: OpenWitGenericEntityId) throws -> [U]
}

extension EntitiesCompatible {
    public func getEntitities<U: Mappable>(for entityId: String) throws -> [U] {
        guard let entities = jsonEntities?[entityId] as? [[String : Any]] else {
            throw OpenWitEntityError.unknownEntity
        }
        guard let mappedArray = Mapper<U>().mapArray(JSONArray: entities) else {
            throw OpenWitEntityError.mappingFailed
        }
        return mappedArray
    }
    
    public func getGenericEntities<U: Mappable>(for genericEntityId: OpenWitGenericEntityId) throws -> [U] {
        return try getEntitities(for: genericEntityId.rawValue)
    }
}


/// A Model to handle Wit Message Response
public struct OpenWitMessageModel: Mappable, EntitiesCompatible {
    
    public fileprivate(set) var msgId: String?
    public fileprivate(set) var text: String?
    public fileprivate(set) var jsonEntities: [String: Any]?
    
    public init?(map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        msgId           <- map[OpenWitJsonKey.messageId.rawValue]
        text            <- map[OpenWitJsonKey.text.rawValue]
        jsonEntities = map.JSON[OpenWitJsonKey.entities.rawValue] as? [String: Any]
    }
}

extension OpenWitMessageModel {
    public var intents: [OpenWitIntentEntityModel]? {
        return try? getGenericEntities(for: .intent)
    }
    
    public var locations: [OpenWitLocationEntityModel]? {
        return try? getGenericEntities(for: .witLocation)
    }
}
