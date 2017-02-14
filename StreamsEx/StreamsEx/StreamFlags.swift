//
//  StreamFlags.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 14.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

struct StreamFlags : OptionSet {
    let rawValue: Int
    
    static let ordered         = StreamFlags(rawValue: 1 << 0)
    static let distinct        = StreamFlags(rawValue: 1 << 1)
    static let sized           = StreamFlags(rawValue: 1 << 2)
    static let sorted          = StreamFlags(rawValue: 1 << 3)
    static let shortCircuit    = StreamFlags(rawValue: 1 << 4)
    
}


extension StreamFlags {
    init(characteristics: SpliteratorCharacteristics) {
        self.rawValue = 0
    }
}
