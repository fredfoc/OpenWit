//
//  OpenWitMessageExtension.swift
//  OpenWit
//
//  Created by fauquette fred on 24/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper


// MARK: - an extension to handle message analyse
extension OpenWit {
    /// get message recognition for WIT
    ///
    /// - Parameters:
    ///   - message: a String with your message
    ///   - messageId: optional id of message
    ///   - threadId: optional thread of the message
    ///   - context: optional context of the message
    ///   - completion: completion closure
    public func message(_ message: String,
                        messageId: String? = nil,
                        threadId: String? = nil,
                        context: Mappable? = nil,
                        completion: @escaping (_ result: OpenWitResult<OpenWitMessageModel, OpenWitError>) -> ()) {
        guard let serviceManager = try? OpenWitServiceManager(WitToken: WITTokenAcces, serverToken: WITServerTokenAcces, isMocked: isMocked) else {
            completion(OpenWitResult(failure: OpenWitError.tokenIsUndefined))
            return
        }
        
        guard message.isNotTooLong else {
            completion(OpenWitResult(failure: OpenWitError.messageTooLong))
            return
        }
        
        _ = serviceManager.provider.requestObject(OpenWitService.message(apiVersion: apiVersion,
                                                                         message: message,
                                                                         messageId: messageId,
                                                                         threadId: threadId,
                                                                         context: context),
                                                  completion: completion)
    }
}
