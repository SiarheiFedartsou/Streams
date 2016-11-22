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
  
    func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T>
    func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R>
    
    
    
    func limit(_ size: Int) -> Stream<T>
    func skip(_ size: Int) -> Stream<T>
    
    func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    
    func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    
    func forEach(_ each: @escaping (T) -> ())
    var first: T? { get }
    var any: T? { get }
    
}

class Stream<T> : StreamProtocol {
    
    
    
    var spliterator: AnySpliterator<T> {
        _abstract()
    }
    
    
    func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T>
    {
        _abstract()
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R>
    {
        _abstract()
    }
    
    func limit(_ size: Int) -> Stream<T>
    {
        _abstract()
    }
    
    func skip(_ size: Int) -> Stream<T>
    {
        _abstract()
    }
    
    func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    {
        _abstract()
    }
    
    func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    {
        _abstract()
    }
    
    func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    {
        _abstract()
    }
    
    func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    {
       _abstract()
    }
    
    func forEach(_ each: @escaping (T) -> ())
    {
        _abstract()
    }
    
    var first: T? {
        _abstract()
    }
    
    var any: T? {
        _abstract()
    }

}
