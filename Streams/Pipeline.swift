//
//  Pipeline.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class PipelineStage<T> : ConsumerProtocol, StreamProtocol
{
    func consume(_ t: T) {
    }
    
    private let source: AnySpliterator<T>
    
    init(source: AnySpliterator<T>)
    {
        self.source = source
    }
    
    var spliterator: AnySpliterator<T> {
        return [T]().spliterator
    }
    
    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T>
    {
        let stage = FilterPipelineStage(predicate: predicate)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R>
    {
        return AnyStream(MapPipelineStage(mapper: mapper))
    }
    
    func forEach(_ each: @escaping (T) -> ())
    {
        
    }
}

class MapPipelineStage<In, Out> : ConsumerProtocol, StreamProtocol
{
    
    var nextStage: AnyConsumer<Out>? = nil
    
    let mapper: (In) -> Out
    
    init(mapper: @escaping (In) -> Out)
    {
        self.mapper = mapper
    }
    
    func consume(_ t: In) {
        if let nextStage = self.nextStage {
            nextStage.consume(mapper(t))
        }
    }

    var spliterator: AnySpliterator<Out> {
        return [T]().spliterator
    }
    
    func filter(_ predicate: @escaping (Out) -> Bool) -> AnyStream<Out>
    {
        let stage = FilterPipelineStage(predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (Out) -> R) -> AnyStream<R>
    {
        let stage = MapPipelineStage<Out, R>(mapper: mapper)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func forEach(_ each: @escaping (Out) -> ())
    {
        
    }
}

class FilterPipelineStage<T> : ConsumerProtocol, StreamProtocol
{
    var nextStage: AnyConsumer<T>? = nil
    
    let predicate: (T) -> Bool
    
    init(predicate: @escaping (T) -> Bool)
    {
        self.predicate = predicate
    }
    
    func consume(_ t: T) {
        if let nextStage = self.nextStage {
            if predicate(t) {
                nextStage.consume(t)
            }
        }
    }
    
    var spliterator: AnySpliterator<T> {
        return [T]().spliterator
    }
    
    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T>
    {
        let stage = FilterPipelineStage(predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R>
    {
        let stage = MapPipelineStage(mapper: mapper)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func forEach(_ each: @escaping (T) -> ())
    {
        
    }
}

