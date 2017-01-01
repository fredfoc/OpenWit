//
//  OpenWitConverseExtension.swift
//  OpenWit
//
//  Created by fauquette fred on 8/12/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation

import Foundation
import Moya
import ObjectMapper


// MARK: - an extension to handle converse analyse
extension OpenWit {
    
    
    public func conversationMessage(_ message: String, sessionId: String, context: Mappable? = nil, completion: @escaping (_ result: OpenWitResult<OpenWitConverseModel, OpenWitError>) -> ()) {
        guard let serviceManager = try? OpenWitServiceManager(WitToken: WITTokenAcces, serverToken: WITServerTokenAcces, isMocked: isMocked) else {
            completion(OpenWitResult(failure: OpenWitError.tokenIsUndefined))
            return
        }
        
        guard message.isNotTooLong else {
            completion(OpenWitResult(failure: OpenWitError.messageTooLong))
            return
        }
        
        _ = serviceManager.provider.requestObject(OpenWitService.converseMessage(apiVersion: apiVersion,
                                                                              message: message,
                                                                              sessionId: sessionId,
                                                                              context: context),
                                                  completion: completion)
    }
    
    public func conversationAction(_ action: Mappable, sessionId: String, context: Mappable? = nil, completion: @escaping (_ result: OpenWitResult<OpenWitConverseModel, OpenWitError>) -> ()) {
        guard let serviceManager = try? OpenWitServiceManager(WitToken: WITTokenAcces, serverToken: WITServerTokenAcces, isMocked: isMocked) else {
            completion(OpenWitResult(failure: OpenWitError.tokenIsUndefined))
            return
        }
        _ = serviceManager.provider.requestObject(OpenWitService.action(apiVersion: apiVersion,
                                                                        action: action,
                                                                        sessionId: sessionId,
                                                                        context: context),
                                                  completion: completion)
    }
}
