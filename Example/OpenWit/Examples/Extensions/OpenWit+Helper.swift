//
//  OpenWit+Helper.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 Fred Fauquette. All rights reserved.
//

import Foundation
import OpenWit

/*
 Those extensions can be customised as much as you need them. They are only convenient way to access custom models inside any Wit json mappable model.
 Have a look at OpenWitMessageModel or OpenWitConverseModel
 */

/// get it in message Model
extension OpenWitMessageModel {
    var shopItems: [ShopItemEntity]? {
        return try? getEntitities(for: ShopItemEntity.entityId)
    }
    
    var shopLists: [ShopListEntity]? {
        return try? getEntitities(for: ShopListEntity.entityId)
    }
}

/// get it in converse Model
extension OpenWitConverseModel {
    var shopItem: ShopItemEntity? {
        return try? getEntitities(for: ShopItemEntity.entityId)[0]
    }
    
    var shopList: ShopListEntity? {
        return try? getEntitities(for: ShopListEntity.entityId)[0]
    }
}
