//
//  Spliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 09.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct SpliteratorCharacteristics : OptionSet {
    let rawValue: Int
    
    static let ordered    = SpliteratorCharacteristics(rawValue: 1 << 0)
    static let distinct    = SpliteratorCharacteristics(rawValue: 1 << 1)
    static let sorted    = SpliteratorCharacteristics(rawValue: 1 << 2)
    static let sized    = SpliteratorCharacteristics(rawValue: 1 << 3)
    static let subsized    = SpliteratorCharacteristics(rawValue: 1 << 4)
}

protocol SpliteratorProtocol {
    associatedtype Element
    mutating func advance() -> Element?
    mutating func forEachRemaining(_ each: (Element) -> ())
    mutating func split() -> AnySpliterator<Element>?
    
    var estimatedSize: IntMax { get }
    var exactSize: IntMax? { get }
    var characteristics: SpliteratorCharacteristics { get }
}

extension SpliteratorProtocol {
    mutating func forEachRemaining(_ each: (Element) -> ()) {
        while let element = advance() {
            each(element)
        }
    }
    
    var exactSize: IntMax? {
        if !characteristics.contains(.sized) {
            return nil
        } else {
            return estimatedSize
        }
    }
}

public struct AnySpliterator<T> : SpliteratorProtocol
{
 
    private let box: AnySpliteratorBoxBase<T>
    
    init<Spliterator: SpliteratorProtocol>(_ spliterator: Spliterator) where Spliterator.Element == T
    {
        box = AnySpliteratorBox(spliterator)
    }
    
    mutating func advance() -> T?
    {
        return box.advance()
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void)
    {
        box.forEachRemaining(each)
    }
    
    mutating func split() -> AnySpliterator<T>?
    {
        return box.split()
    }
    
    var estimatedSize: IntMax {
        return box.estimatedSize
    }
    
    var exactSize: IntMax? {
        return box.exactSize
    }
    
    var characteristics: SpliteratorCharacteristics {
        return box.characteristics
    }
    
}

class AnySpliteratorBoxBase<T>: SpliteratorProtocol {
    func advance() -> T? {
        _abstract()
    }
    
    func forEachRemaining(_ each: (T) -> Void) {
        _abstract()
    }
    
    func split() -> AnySpliterator<T>? {
        _abstract()
    }
    
    var estimatedSize: IntMax {
        _abstract()
    }
    
    var exactSize: IntMax? {
        _abstract()
    }
    
    var characteristics: SpliteratorCharacteristics {
        _abstract()
    }
}

final class AnySpliteratorBox<Base: SpliteratorProtocol>: AnySpliteratorBoxBase<Base.Element> {
    private var base: Base
    init(_ base: Base)  {
        self.base = base
    }
    
    override func advance() -> Base.Element? {
        return base.advance()
    }
    
    override func forEachRemaining(_ each: (Base.Element) -> Void) {
        base.forEachRemaining(each)
    }
    
    override func split() -> AnySpliterator<Base.Element>? {
        return base.split()
    }

    override var estimatedSize: IntMax {
        return base.estimatedSize
    }
    
    override var exactSize: IntMax? {
        return base.exactSize
    }
    
    override var characteristics: SpliteratorCharacteristics {
        return base.characteristics
    }

}
