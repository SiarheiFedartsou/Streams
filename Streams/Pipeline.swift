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
    var nextStage: AnyConsumer<T>? = nil
    
    func consume(_ t: T) {
        nextStage?.consume(t)
    }
    
    private var source: AnySpliterator<T>
    
    init(source: AnySpliterator<T>)
    {
        self.source = source
    }
    
    var spliterator: AnySpliterator<T> {
        return [T]().spliterator
    }
    
    func filter(_ predicate: @escaping (T) -> Bool) -> AnyStream<T>
    {
        let stage = FilterPipelineStage(sourceStage: AnyConsumer(self), source: source, predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R>
    {
        let stage = MapPipelineStage(sourceStage: AnyConsumer(self), source: source, mapper: mapper)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func forEach(_ each: @escaping (T) -> ())
    {
        let stage = ForEachTerminalStage(each: each)
        self.nextStage = AnyConsumer(stage)
        
        while let element = source.advance() {
            self.consume(element)
        }
    }
}

class ForEachTerminalStage<T> : ConsumerProtocol {
    
    private let each: (T) -> ()
    
    init(each: @escaping (T) -> ())
    {
        self.each = each
    }
    
    func consume(_ t: T) {
        each(t)
    }
}

class MapPipelineStage<In, Out, SourceElement> : ConsumerProtocol, StreamProtocol
{
    let sourceStage: AnyConsumer<SourceElement>
    private var source: AnySpliterator<SourceElement>
    
    var nextStage: AnyConsumer<Out>? = nil
    
    let mapper: (In) -> Out
    
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, mapper: @escaping (In) -> Out)
    {
        self.sourceStage = sourceStage
        self.source = source
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
        let stage = FilterPipelineStage(sourceStage: self.sourceStage, source: source, predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (Out) -> R) -> AnyStream<R>
    {
        let stage = MapPipelineStage<Out, R, SourceElement>(sourceStage: self.sourceStage, source: source, mapper: mapper)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func forEach(_ each: @escaping (Out) -> ())
    {
        let stage = ForEachTerminalStage(each: each)
        self.nextStage = AnyConsumer(stage)
        
        while let element = source.advance() {
            self.sourceStage.consume(element)
        }
    }
}

class FilterPipelineStage<T, SourceElement> : ConsumerProtocol, StreamProtocol
{
    let sourceStage: AnyConsumer<SourceElement>
    private var source: AnySpliterator<SourceElement>
    
    
    var nextStage: AnyConsumer<T>? = nil
    
    let predicate: (T) -> Bool
    
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, predicate: @escaping (T) -> Bool)
    {
        self.sourceStage = sourceStage
        self.source = source
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
        let stage = FilterPipelineStage(sourceStage: self.sourceStage, source: source, predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (T) -> R) -> AnyStream<R>
    {
        let stage = MapPipelineStage(sourceStage: self.sourceStage, source: source, mapper: mapper)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func forEach(_ each: @escaping (T) -> ())
    {
        let stage = ForEachTerminalStage(each: each)
        self.nextStage = AnyConsumer(stage)
        
        while let element = source.advance() {
            self.sourceStage.consume(element)
        }
    }
}

