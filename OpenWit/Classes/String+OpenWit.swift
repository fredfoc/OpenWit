//
//  String+OpenWit.swift
//  OpenWit
//
//  Created by fauquette fred on 16/12/16.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import Foundation


extension String {
    var isNotTooLong: Bool {
        return characters.count < 256
    }
}
