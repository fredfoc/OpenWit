//
//  OpenWitService.swift
//  OpenWit
//
//  Created by fauquette fred on 22/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import Moya_ObjectMapper
import CoreAudio


enum OpenWitService {
    case entities(apiVersion:String)
    case message(apiVersion:String, message: String, messageId: String?, threadId: String?, context: Mappable?)
    case speech(apiVersion:String, audioFile: Data, audioFormat: AudioFormatID, messageId: String?, threadId: String?, context: Mappable?)
    case converseMessage(apiVersion:String, message: String, sessionId: String, context: Mappable?)
    case action(apiVersion:String, action: Mappable, sessionId: String, context: Mappable?)
}

extension OpenWitService: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.wit.ai")!
    }
    
    var path: String {
        switch self {
        case .message:
            return "/message"
        case .entities:
            return "/entities"
        case .speech:
            return "/speech"
        case .converseMessage, .action:
            return "/converse"
        }
    }
    var method: Moya.Method {
        switch self {
        case .message, .entities:
            return .get
        default:
            return .post
        }
        
    }

    var parameters: [String: Any]? {
        switch self {
        case .message(let apiVersion, let message, let messageId, let threadId, let context):
            var params = [
                "v": apiVersion,
                "q": message
            ]
            if let contextString = context?.toJSONString() {
                params["context"] = contextString
            }
            if let messageId = messageId {
                params["msg_id"] = messageId
            }
            if let threadId = threadId {
                params["thread_id"] = threadId
            }
            return params
        case .entities(let apiVersion):
            return
                [
                    "v": apiVersion,
            ]
        case .speech:
            return nil
        case .converseMessage(_, _, _, let context):
            if let context = context {
                return context.toJSON()
            }
            return nil
        case .action(_, let action,_,_):
            return action.toJSON()
        }
        
    }

    var sampleData: Data {
        switch self {
        case .message:
            return OpenWitService.JSONDataFromFile("message")
        case .entities:
            return OpenWitService.JSONDataFromFile("entities")
        case .speech:
            return OpenWitService.JSONDataFromFile("message")
        case .converseMessage:
            return OpenWitService.JSONDataFromFile("message")
        case .action:
            return OpenWitService.JSONDataFromFile("message")
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .message, .entities, .speech:
            return URLEncoding()
        case .converseMessage, .action:
            return JSONEncoding()
        }
    }
    
    var task: Task {
        return .request
    }
    
    var multipartBody: [MultipartFormData]? {
        switch self {
        case .speech(_, let audioFile, _, _, _, _):
            return [MultipartFormData(provider: .data(audioFile), name: "sample")]
        default:
            return nil
        }
    }
    
    static var mainBundle = Bundle.main
    
    static func JSONDataFromFile(_ fileName: String) -> Data {
        if let str = OpenWitService.mainBundle.path(forResource: fileName, ofType: "json") {
            return (try! Data(contentsOf: URL(fileURLWithPath: str)))
        } else {
            return Data()
        }
    }
}

extension MoyaProvider {
    public func requestObject<U: Mappable>(_ target: Target, completion: @escaping (_ result: OpenWitResult<U, OpenWitError>) -> ())  -> Cancellable? {
        return request(target, completion: { result in            
            switch result {
            case let .success(response):
                switch response.handledStatusCode {
                case .noError:
                    do {
                        let object = try response.mapObject(U.self)
                        completion(OpenWitResult(success: object))
                    } catch {
                        completion(OpenWitResult(failure: OpenWitError.jsonMapping(response)))
                    }
                default:
                    completion(OpenWitResult(failure: OpenWitError.networkError(response)))
                }
                
            case let .failure(error):
                completion(OpenWitResult(failure: OpenWitError.underlying(error)))
            }
        })
    }
}

extension Moya.Response {
    var handledStatusCode: OpenWitError {
        switch statusCode {
        case 100..<200:
            return .progress
        case 200..<300:
            return .noError
        case 300..<400:
            return .redirection(statusCode)
        case 400..<500:
            return .authentication(statusCode)
        case 500..<600:
            return .internalError(statusCode)
        default:
            return .unknown
        }
    }
}
