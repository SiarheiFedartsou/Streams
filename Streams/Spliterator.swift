//
//  Spliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 09.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation



protocol SpliteratorProtocol {
    associatedtype T
    mutating func advance() -> T?
    mutating func forEachRemaining(_ each: (T) -> Void)
    mutating func split() -> AnySpliterator<T>?
    
    var options: StreamOptions { get }
    var estimatedSize: Int { get }
}

struct AnySpliterator<T> : SpliteratorProtocol
{
 
    private let box: AnySpliteratorBoxBase<T>
    
    init<Spliterator: SpliteratorProtocol>(_ spliterator: Spliterator) where Spliterator.T == T
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
    
    var options: StreamOptions {
        return box.options
    }
    
    var estimatedSize: Int {
        return box.estimatedSize
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
    
    var options: StreamOptions {
        _abstract()
    }
    
    var estimatedSize: Int {
        _abstract()
    }
}

final class AnySpliteratorBox<Base: SpliteratorProtocol>: AnySpliteratorBoxBase<Base.T> {
    private var base: Base
    init(_ base: Base)  {
        self.base = base
    }
    
    override func advance() -> Base.T? {
        return base.advance()
    }
    
    override func forEachRemaining(_ each: (Base.T) -> Void) {
        base.forEachRemaining(each)
    }
    
    override func split() -> AnySpliterator<Base.T>? {
        return base.split()
    }
    
    override var options: StreamOptions {
        return base.options
    }
    
    override var estimatedSize: Int {
        return base.estimatedSize
    }
}
