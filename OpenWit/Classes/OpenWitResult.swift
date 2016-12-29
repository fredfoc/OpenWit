//
//  OpenWitResult.swift
//  OpenWit
//
//  Created by fauquette fred on 22/11/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya


public enum OpenWitResult<T, E: Swift.Error> {
    case success(T)
    case failure(E)
    
    public init(success: T){
        self = .success(success)
    }
    
    public init(failure: E) {
        self = .failure(failure)
    }
}
