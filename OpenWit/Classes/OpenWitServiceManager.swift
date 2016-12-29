//
//  ServiceManager.swift
//  OpenWit
//
//  Created by fauquette fred on 22/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import CoreAudio

/// the class to implement the services
class OpenWitServiceManager {
    
    let provider: MoyaProvider<OpenWitService>
    
    init(WitToken: String?, serverToken: String?, isMocked: Bool) throws {
        guard let WitToken = WitToken else {
            throw OpenWitError.tokenIsUndefined
        }
        guard let serverToken = serverToken else {
            throw OpenWitError.serverTokenIsUndefined
        }
        let stubClosure: MoyaProvider<OpenWitService>.StubClosure
        if isMocked {
            stubClosure = { (_: OpenWitService) -> Moya.StubBehavior in return .immediate }
        } else {
            stubClosure = { (_: OpenWitService) -> Moya.StubBehavior in return .never }
        }
        
        let manager = Manager()
        manager.startRequestsImmediately = false
        
        provider = MoyaProvider(endpointClosure: { (target: OpenWitService) -> Endpoint<OpenWitService> in
            var urlParams: [String:String]?
            switch target {
            case .speech(let apiVersion, _, _, _, _, let context):
                urlParams = ["version": apiVersion]
                if let contextString = context?.toJSONString() {
                    urlParams?["context"] = contextString
                }
            case .converseMessage(let apiVersion, let message, let sessionId, _):
                urlParams = ["version": apiVersion,
                             "session_id": sessionId,
                             "q" :message]
            case .action(let apiVersion, _, let sessionId, let context):
                urlParams = ["version": apiVersion,
                             "session_id": sessionId]
                if let contextString = context?.toJSONString() {
                    urlParams?["context"] = contextString
                }
            default:
                break
            }
            var url = target.baseURL.appendingPathComponent(target.path).absoluteString
            if let urlParams = urlParams {
                url += "?" + urlParams.urlEncoded
            }
            var endPoint = Endpoint<OpenWitService>(url: url,
                sampleResponseClosure: {EndpointSampleResponse.networkResponse(200, target.sampleData)},
                method: target.method,
                parameters: target.parameters,
                parameterEncoding: target.parameterEncoding)
            
            switch target {
            case .entities:
                endPoint = endPoint.adding(newHTTPHeaderFields: [
                    "Authorization": "Bearer \(serverToken)"
                    ])
            case .speech(_ , _, let audioFormat, _, _, _):
                let contentType: String
                
                switch audioFormat {
                case kAudioFormatULaw:
                    contentType = "audio/ulaw";
                case kAudioFormatAppleIMA4:
                    contentType = "audio/raw;encoding=ima-adpcm;bits=16;rate=16000;endian=little";
                case kAudioFormatLinearPCM:
                    contentType = "wit/ios";
                default:
                    contentType = "wit/ios";
                }
                let headers = [
                    "Authorization": "Bearer \(WitToken)",
                    "content-type": contentType
                    ]
                
                endPoint = endPoint.adding(newHTTPHeaderFields: headers)
                
            default:
                endPoint = endPoint.adding(newHTTPHeaderFields: [
                    "Authorization": "Bearer \(WitToken)"
                    ])
            }
            
            return endPoint
            },
                                stubClosure: stubClosure,
                                manager: manager)
    }    
    
}

extension Dictionary where Key: CustomStringConvertible, Value: CustomStringConvertible {
    var urlEncoded: String {
        return String(
            map{
                ("&" + $0.key.description + "=" + $0.value.description).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                }.reduce("", +).characters.dropFirst())
    }
}


