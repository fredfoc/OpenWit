//
//  OpenWitAllEntitiesExtension.swift
//  OpenWit
//
//  Created by fauquette fred on 24/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import Moya


// MARK: - an extension to handle all entities request
extension OpenWit {
    
    /// get all entities and receive them as a OpenWitAllEntitiesModel Model
    ///
    /// - Parameter completion: a completion block to handle the asynchronous call (see OpenWitError for more details about potential errors)
    public func getEntities(completion: @escaping (_ result: OpenWitResult<OpenWitAllEntitiesModel, OpenWitError>) -> ()) {
        guard let serviceManager = try? OpenWitServiceManager(WitToken: WITTokenAcces, serverToken: WITServerTokenAcces, isMocked: isMocked) else {
            completion(OpenWitResult(failure: OpenWitError.tokenIsUndefined))
            return
        }
        _ = serviceManager.provider.request(OpenWitService.entities(apiVersion: apiVersion),
                                            completion: { (result) in
                                                switch result {
                                                case .success(let moyaResponse):
                                                    switch moyaResponse.handledStatusCode {
                                                    case .noError:
                                                        do {
                                                            if let entityIds = try JSONSerialization.jsonObject(with: moyaResponse.data, options: .allowFragments) as? [String] {
                                                                completion(OpenWitResult(success: OpenWitAllEntitiesModel(entityIds : entityIds)))
                                                            } else {
                                                                completion(OpenWitResult(failure: OpenWitError.jsonMapping(moyaResponse)))
                                                            }
                                                            
                                                        } catch {
                                                            completion(OpenWitResult(failure: OpenWitError.jsonMapping(moyaResponse)))
                                                        }
                                                    default:
                                                        completion(OpenWitResult(failure: OpenWitError.networkError(moyaResponse)))
                                                    }
                                                case .failure(let error):
                                                    completion(OpenWitResult.failure(OpenWitError.underlying(error)))
                                                }
        })
    }

}
