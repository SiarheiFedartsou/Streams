//
//  Stream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.10.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation
import Swift

protocol StreamProtocol {
    associatedtype T
    var spliterator: AnySpliterator<T> { get }
    
    var isParallel: Bool { get }
    
    var parallel: AnyStream<T> { get }
    var sequential: AnyStream<T> { get }
    var unordered: AnyStream<T> { get }
    
    
    func filter(_ predicate: (T) -> Bool) -> AnyStream<T>
    func map<R>(_ mapper: (T) -> R) -> AnyStream<R>
    
    func forEach(_ each: (T) -> ())
}


struct Stream<T> : StreamProtocol {
    let spliterator: AnySpliterator<T>
    
    let isParallel: Bool
    
    var parallel: AnyStream<T> {
        return AnyStream(self)
    }
    
    var sequential: AnyStream<T> {
        return AnyStream(self)
    }
    
    var unordered: AnyStream<T> {
        return AnyStream(self)
    }
    
    func filter(_ predicate: (T) -> Bool) -> AnyStream<T> {
        return AnyStream(self)
    }
    
    func map<R>(_ mapper: (T) -> R) -> AnyStream<R> {
        return [R]().stream
    }
    
    func forEach(_ each: (T) -> ()) {
        
    }
    
    
    init(spliterator: AnySpliterator<T>, parallel: Bool)
    {
        self.spliterator = spliterator
        self.isParallel = parallel
    }
}
