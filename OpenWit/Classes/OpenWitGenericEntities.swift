//
//  OpenWitIntentModel.swift
//  OpenWit
//
//  Created by fauquette fred on 23/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import ObjectMapper


/// an enum to handle generic Wit entities (see models below)
///
/// - intent: (implemented)
/// - witQuantity: (not implemented)
/// - witMessageBody: (not implemented)
/// - witLocalSearchQuery: (not implemented)
/// - witDuration: (not implemented)
/// - witAgeOfPerson: (not implemented)
/// - witMathExpression: (not implemented)
/// - witPhoneNumber: (not implemented)
/// - witAgendaEntry: (not implemented)
/// - witOrdinal: (not implemented)
/// - witDistance: (not implemented)
/// - witContact: (not implemented)
/// - witEmail: (not implemented)
/// - witMessageSubject: (not implemented)
/// - witLocation: (implemented)
/// - witAmountOfMoney: (not implemented)
/// - witPhraseToTranslate: (not implemented)
/// - witWDateTime: (not implemented)
/// - witDateTime: (not implemented)
/// - witReminder: (not implemented)
/// - witSearchQuery: (not implemented)
/// - witOnOff: (not implemented)
/// - witAudioSearchQuery: (not implemented)
/// - witURL: (not implemented)
/// - witWolframSearchQuery: (not implemented)
/// - witNumber: (not implemented)
/// - witTemperature: (not implemented)
public enum OpenWitGenericEntityId: String {
    case intent = "intent"
    case witQuantity = "quantity"
    case witMessageBody = "message_body"
    case witLocalSearchQuery = "local_search_query"
    case witDuration = "duration"
    case witAgeOfPerson = "age_of_person"
    case witMathExpression = "math_expression"
    case witPhoneNumber = "phone_number"
    case witAgendaEntry = "agenda_entry"
    case witOrdinal = "ordinal"
    case witDistance = "distance"
    case witContact = "contact"
    case witEmail = "email"
    case witMessageSubject = "message_subject"
    case witLocation = "location"
    case witAmountOfMoney = "amount_of_money"
    case witPhraseToTranslate = "phrase_to_translate"
    case witWDateTime = "wdatetime"
    case witDateTime = "datetime"
    case witReminder = "reminder"
    case witSearchQuery = "search_query"
    case witOnOff = "on_off"
    case witAudioSearchQuery = "wikipedia_search_query"
    case witURL = "url"
    case witWolframSearchQuery = "wolfram_search_query"
    case witNumber = "number"
    case witTemperature = "temperature"
    
    static func isGenericEntity(entityId: String) -> Bool {
        return OpenWitGenericEntityId(rawValue: entityId) != nil
    }
    
    var genericId: String {
        switch self {
        case .intent:
            return rawValue
        default:
            return "wit$" + rawValue
        }
    }
}

public struct OpenWitAllEntitiesModel {
    public fileprivate(set) var entityIds: [String]?
    
    init(entityIds: [String]?) {
        self.entityIds = entityIds
    }
}

public protocol OpenWitGenericEntityModelProtocol {
    var suggested: Bool {get set}
    var confidence: Float?  {get set}
    var type: String?  {get set}
    var value: String?  {get set}
}

extension OpenWitGenericEntityModelProtocol where Self: Mappable {
    mutating public func mapping(map: Map) {
        confidence          <- map[OpenWitJsonKey.confidence.rawValue]
        type                <- map[OpenWitJsonKey.type.rawValue]
        value               <- map[OpenWitJsonKey.mainValue.rawValue]
        suggested           <- map[OpenWitJsonKey.suggested.rawValue]
    }
}

public struct OpenWitIntentEntityModel: Mappable, OpenWitGenericEntityModelProtocol {
    public var suggested: Bool = false
    public var confidence: Float?
    public var type: String?
    public var value: String?
    
    public init?(map: Map) {}
}

public struct OpenWitLocationEntityModel: Mappable, OpenWitGenericEntityModelProtocol {
    public var suggested: Bool = false
    public var confidence: Float?
    public var type: String?
    public var value: String?
    
    public init?(map: Map) {}
}
