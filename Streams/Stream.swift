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
  
    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T>
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R>
    
    
    
    func limit(_ size: Int) -> AnyStream<T>
    func skip(_ size: Int) -> AnyStream<T>
    
    func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    
    func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    
    func forEach(_ each: @escaping (T) -> ())
    var first: T? { get }
    var any: T? { get }
}

extension StreamProtocol where Self : PipelineStageProtocol, Self.Output == T {
    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T>
    {
       return AnyStream(FilterPipelineStage(previousStage: self, predicate: predicate))
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R>
    {
        return AnyStream(MapPipelineStage<T, R, SourceElement>(previousStage: self, mapper: mapper))
    }
    
    func limit(_ size: Int) -> AnyStream<T>
    {
        return AnyStream(LimitPipelineStage<T, SourceElement>(previousStage: self, size: size))
    }
    
    func skip(_ size: Int) -> AnyStream<T>
    {
        return AnyStream(SkipPipelineStage<T, SourceElement>(previousStage: self, size: size))
    }
}

extension StreamProtocol where T : Comparable, Self : PipelineStageProtocol, Self.Output == T {
    func sorted() -> AnyStream<T> {
        return AnyStream(SortedPipelineStage(previousStage: self, by: <))
    }
    
    func sorted(by comparator: @escaping (T, T) -> Bool) -> AnyStream<T> {
        return AnyStream(SortedPipelineStage(previousStage: self, by: comparator))
    }
}
