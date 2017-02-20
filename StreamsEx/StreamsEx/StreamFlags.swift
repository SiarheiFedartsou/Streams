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
    init(modifiers: StreamFlagsModifiers) {
        self = StreamFlags().applying(modifiers: modifiers)
    }
}

extension StreamFlags {
    func applying(modifiers: StreamFlagsModifiers) -> StreamFlags {
        var flags = self
        if modifiers.contains(.ordered) {
            flags.insert(.ordered)
        } else if modifiers.contains(.notOrdered) {
            flags.remove(.ordered)
        }
        if modifiers.contains(.distinct) {
            flags.insert(.distinct)
        } else if modifiers.contains(.notDistinct) {
            flags.remove(.distinct)
        }
        if modifiers.contains(.sized) {
            flags.insert(.sized)
        } else if modifiers.contains(.notSized) {
            flags.remove(.sized)
        }
        if modifiers.contains(.sorted) {
            flags.insert(.sorted)
        } else if modifiers.contains(.notSorted) {
            flags.remove(.sorted)
        }
        if modifiers.contains(.shortCircuit) {
            flags.insert(.shortCircuit)
        } else if modifiers.contains(.notShortCircuit) {
            flags.remove(.shortCircuit)
        }
        return flags
    }
}


struct StreamFlagsModifiers : OptionSet {
    let rawValue: Int
    
    static let ordered         = StreamFlagsModifiers(rawValue: 1 << 0)
    static let distinct        = StreamFlagsModifiers(rawValue: 1 << 1)
    static let sized           = StreamFlagsModifiers(rawValue: 1 << 2)
    static let sorted          = StreamFlagsModifiers(rawValue: 1 << 3)
    static let shortCircuit    = StreamFlagsModifiers(rawValue: 1 << 4)
    
    static let notOrdered         = StreamFlagsModifiers(rawValue: 1 << 5)
    static let notDistinct        = StreamFlagsModifiers(rawValue: 1 << 6)
    static let notSized           = StreamFlagsModifiers(rawValue: 1 << 7)
    static let notSorted          = StreamFlagsModifiers(rawValue: 1 << 8)
    static let notShortCircuit    = StreamFlagsModifiers(rawValue: 1 << 9)
    
}

extension StreamFlagsModifiers {
    init(characteristics: SpliteratorCharacteristics) {
        var modifiers = StreamFlagsModifiers()
        
        if characteristics.contains(.ordered) {
            modifiers.insert(.ordered)
        }
        if characteristics.contains(.distinct) {
            modifiers.insert(.distinct)
        }
        if characteristics.contains(.sized) {
            modifiers.insert(.sized)
        }
        if characteristics.contains(.sorted) {
            modifiers.insert(.sorted)
        }
        
        self = modifiers
    }
}
