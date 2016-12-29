//
//  OpenWit.swift
//  OpenWit
//
//  Created by fauquette fred on 22/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import ObjectMapper
import CoreAudio


/// potential OpenWit Errors
///
/// - tokenIsUndefined: Wit token is not defined
/// - serverTokenIsUndefined: server Wit token is not defined
/// - noError: no Error (used to handle the statuscode of an answer
/// - jsonMapping: jsonMapping failed
/// - serialize: serializing failed
/// - networkError: network error
/// - underlying: underlying moya error
/// - internalError: internal server error (500...)
/// - authentication: authentication error (400...)
/// - progress: progress statuscode (this is considered as an error but that should probably not be... pobody's nerfect)
/// - redirection: redirection statuscode (this is considered as an error but that should probably not be... pobody's nerfect)
/// - messageNotEncodedCorrectly: encoding of message was not possible
/// - messageTooLong: message can not be more than 256 characters
/// - unknown: something strange happened and it can not be described... aliens, anarchie, utopia...
public enum OpenWitError: Swift.Error {
    case tokenIsUndefined
    case serverTokenIsUndefined
    case noError
    case jsonMapping(Moya.Response?)
    case serialize(Moya.Response?)
    case networkError(Moya.Response?)
    case underlying(Moya.Error)
    case internalError(Int)
    case authentication(Int)
    case progress
    case redirection(Int)
    case messageNotEncodedCorrectly
    case messageTooLong
    case unknown
}

enum OpenWitJsonKey: String {
    case entities = "entities"
    case quickreplies = "quickreplies"
    case type = "type"
    case confidence = "confidence"
    case text = "_text"
    case messageId = "msg_id"
    case mainValue = "value"
    case suggested = "suggested"
}


/// some error to handle the parsing of wit entities
///
/// - unknownEntity: the entity is not known
/// - mappingFailed: mapping failed (we could not parse the json to the mappable class you requested
public enum OpenWitEntityError: Swift.Error {
    case unknownEntity
    case mappingFailed
}

///See extension to get specific functionalities

/// the OpenWit singleton class
public class OpenWit {
    
    /// the sharedInstance as this is a Singleton
    public static let sharedInstance = OpenWit()
    
    /// WIT Token access, for public calls like message, speech, converse (should be set in AppDelegate or when needed)
    public var WITTokenAcces: String?
    /// WIT Server access (used in some calls - to get all entities for example)
    public var WITServerTokenAcces: String?
    /// a value used if you want to mock all the answers
    public var isMocked = false
    /// the api version (see WIT documentation to change it - at the time this was done it was: 20160526)
    public var apiVersion = "20160526"
    
    private init(){
    }
    
}
