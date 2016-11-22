//
//  Stream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.10.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation
import Swift

protocol StreamProtocol : PipelineStageProtocol {
    associatedtype T
    var spliterator: AnySpliterator<T> { get }
  
    func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T, SourceElement>
    func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R, SourceElement>
    
    
    
    func limit(_ size: Int) -> Stream<T, SourceElement>
    func skip(_ size: Int) -> Stream<T, SourceElement>
    
    func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    
    func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    
    func forEach(_ each: @escaping (T) -> ())
    var first: T? { get }
    var any: T? { get }
}

class Stream<T, SourceElement> : StreamProtocol {
    
    var nextStage: AnySink<T>? = nil
    var source: AnySpliterator<SourceElement>
    var sourceStage: AnySink<SourceElement>? = nil
    
    init(source: AnySpliterator<SourceElement>) {
       self.source = source
    }
    
    var spliterator: AnySpliterator<T> {
        _abstract()
    }

    
    func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T, SourceElement>
    {
        return FilterPipelineStage(previousStage: self, predicate: predicate)
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R, SourceElement>
    {
        return MapPipelineStage(previousStage: self, mapper: mapper)
    }
    
    func limit(_ size: Int) -> Stream<T, SourceElement>
    {
        return LimitPipelineStage<T, SourceElement>(previousStage: self, size: size)
    }
    
    func skip(_ size: Int) -> Stream<T, SourceElement>
    {
        return SkipPipelineStage<T, SourceElement>(previousStage: self, size: size)
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
