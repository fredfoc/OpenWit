//
//  OpenWitSpeechExtension.swift
//  OpenWit
//
//  Created by fauquette fred on 24/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import Moya
import CoreAudio
import ObjectMapper


// MARK: - an extension to enable speech recognition ((not implemented correctly at the moment)
extension OpenWit {
    
    /// get speech recognition for WIT
    ///
    /// - Parameters:
    ///   - audioFile: the data coming from an audiofile
    ///   - audioFormat: the audioformat (see AudioFormatID)
    ///   - messageId: optional id of message
    ///   - threadId: optional thread of the message
    ///   - context: optional context of the message
    ///   - completion: completion closure
    public func speech(audioFile: Data,
                       audioFormat: AudioFormatID,
                       messageId: String? = nil,
                       threadId: String? = nil,
                       context: Mappable? = nil,
                       completion: @escaping (_ result: OpenWitResult<OpenWitMessageModel, OpenWitError>) -> ()) {
        guard let serviceManager = try? OpenWitServiceManager(WitToken: WITTokenAcces, serverToken: WITServerTokenAcces, isMocked: isMocked) else {
            completion(OpenWitResult(failure: OpenWitError.tokenIsUndefined))
            return
        }
        _ = serviceManager.provider.requestObject(OpenWitService.speech(apiVersion: apiVersion,
                                                                        audioFile: audioFile,
                                                                        audioFormat: audioFormat,
                                                                        messageId: messageId,
                                                                        threadId: threadId,
                                                                        context: context),
                                                  completion: completion)
        }
}
