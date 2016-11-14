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
}

struct AnySpliterator<T> : SpliteratorProtocol
{
 
    private let _advance: () -> T?
    private let _forEachRemaining: ((T) -> ()) -> ()
    private let _split: () -> AnySpliterator<T>?
    
    init<Spliterator: SpliteratorProtocol>(_ spliterator: Spliterator) where Spliterator.T == T
    {
        var mutableSpliterator = spliterator
        
        _advance = { mutableSpliterator.advance() }
        _forEachRemaining = { mutableSpliterator.forEachRemaining($0) }
        _split = { mutableSpliterator.split() }
    }
    
    mutating func advance() -> T?
    {
        return _advance()
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void)
    {
        _forEachRemaining(each)
    }
    
    mutating func split() -> AnySpliterator<T>?
    {
        return _split()
    }
    
}
