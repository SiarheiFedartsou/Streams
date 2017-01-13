//
//  StreamOptions.swift
//  Streams
//
//  Created by Sergey Fedortsov on 09.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct StreamOptions : OptionSet {
    let rawValue: Int
    
    static let ordered    = StreamOptions(rawValue: 1 << 0)
    static let distinct  = StreamOptions(rawValue: 1 << 1)
    static let sorted    = StreamOptions(rawValue: 1 << 2)
    static let sized  = StreamOptions(rawValue: 1 << 3)
    static let subsized  = StreamOptions(rawValue: 1 << 4)
}
