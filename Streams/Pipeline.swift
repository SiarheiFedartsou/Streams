//
//  Pipeline.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class PipelineHead<T> : PipelineStage<T, T, T>
{
    init(source: AnySpliterator<T>)
    {
        super.init(sourceStage: nil, source: source)
        self.sourceStage = AnyConsumer(self)
    }
    
    override func consume(_ t: T) {
        nextStage?.consume(t)
    }
    
}

class PipelineStage<In, Out, SourceElement> : ConsumerProtocol, StreamProtocol
{
    var nextStage: AnyConsumer<Out>? = nil
    
    func consume(_ t: In) {}
    
    private var source: AnySpliterator<SourceElement>
    var sourceStage: AnyConsumer<SourceElement>? = nil
    
    
    init(sourceStage: AnyConsumer<SourceElement>?, source: AnySpliterator<SourceElement>)
    {
        self.source = source
        self.sourceStage = sourceStage
    }
    
    var spliterator: AnySpliterator<Out> {
        return [Out]().spliterator
    }
    
    func filter(_ predicate: @escaping (Out) -> Bool) -> AnyStream<Out>
    {
        let stage = FilterPipelineStage(sourceStage: self.sourceStage!, source: source, predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (Out) -> R) -> AnyStream<R>
    {
        let stage = MapPipelineStage(sourceStage: self.sourceStage!, source: source, mapper: mapper)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func limit(_ size: Int) -> AnyStream<Out>
    {
        let stage = LimitPipelineStage<Out, SourceElement>(sourceStage: self.sourceStage!, source: source, size: size)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func skip(_ size: Int) -> AnyStream<Out>
    {
        let stage = SkipPipelineStage<Out, SourceElement>(sourceStage: self.sourceStage!, source: source, size: size)
        self.nextStage = AnyConsumer(stage)
        return AnyStream(stage)
    }
    
    func reduce(identity: Out, accumulator: @escaping (Out, Out) -> Out) -> Out
    {
        let stage = ReduceTerminalStage(source: source, sourceStage: sourceStage!, identity: identity, accumulator: accumulator)
        self.nextStage = AnyConsumer(stage)
        
        return stage.evaluate()
    }
    
    func anyMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(source: source, sourceStage: sourceStage!, predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        
        return stage.evaluate()
    }
    
    func allMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(source: source, sourceStage: sourceStage!, predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        
        return stage.evaluate()
    }
    
    func noneMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(source: source, sourceStage: sourceStage!, predicate: predicate)
        self.nextStage = AnyConsumer(stage)
        
        return stage.evaluate()
    }
    
    func forEach(_ each: @escaping (Out) -> ())
    {
        let stage = ForEachTerminalStage(source: source, sourceStage: sourceStage!, each: each)
        self.nextStage = AnyConsumer(stage)
        
        stage.evaluate()
    }
    
    var first: Out? {
        return nil
    }
    
    var any: Out? {
        return nil
    }
}

protocol TerminalStage : ConsumerProtocol {
    associatedtype Result
    func evaluate() -> Result
}

class ReduceTerminalStage<T, SourceElement> : TerminalStage {
    private var source: AnySpliterator<SourceElement>
    private var sourceStage: AnyConsumer<SourceElement>
    
    
    private var identity: T
    private var accumulator: (T, T) -> T
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnyConsumer<SourceElement>, identity: T, accumulator: @escaping (T, T) -> T)
    {
        self.source = source
        self.sourceStage = sourceStage
        self.identity = identity
        self.accumulator = accumulator
    }
    
    private var noneMatch: Bool = false
    
    func consume(_ t: T) {
        identity = accumulator(identity, t)
    }
    
    func evaluate() -> T {
        while let element = source.advance() {
            sourceStage.consume(element)
        }
        return identity
    }
}


class NoneMatchTerminalStage<T, SourceElement> : TerminalStage {
    private let predicate: (T) -> (Bool)
    private var source: AnySpliterator<SourceElement>
    private var sourceStage: AnyConsumer<SourceElement>
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnyConsumer<SourceElement>, predicate: @escaping (T) -> Bool)
    {
        self.source = source
        self.sourceStage = sourceStage
        self.predicate = predicate
    }
    
    private var noneMatch: Bool = false
    
    func consume(_ t: T) {
        if !predicate(t) {
            noneMatch = true
        }
    }
    
    func evaluate() -> Bool {
        while let element = source.advance() {
            sourceStage.consume(element)
        }
        return noneMatch
    }
}

class ForEachTerminalStage<T, SourceElement> : TerminalStage {
    
    private let each: (T) -> ()
    private var source: AnySpliterator<SourceElement>
    private var sourceStage: AnyConsumer<SourceElement>
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnyConsumer<SourceElement>, each: @escaping (T) -> ())
    {
        self.source = source
        self.sourceStage = sourceStage
        self.each = each
    }
    
    func consume(_ t: T) {
        each(t)
    }
    
    func evaluate() -> Void {
        while let element = source.advance() {
            sourceStage.consume(element)
        }
    }
}

class LimitPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement>
{
    var size: Int
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, size: Int)
    {
        self.size = size
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func consume(_ t: T) {
        if size > 0 {
            if let nextStage = self.nextStage {
                size -= 1
                nextStage.consume(t)
            }
        }
    }
}

class SkipPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement>
{
    let sizeToSkip: Int
    var skipped: Int = 0
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, size: Int)
    {
        self.sizeToSkip = size
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func consume(_ t: T) {
        if (skipped == sizeToSkip) {
            if let nextStage = self.nextStage {
                nextStage.consume(t)
            }
        } else {
            skipped += 1
        }
    }
}

class MapPipelineStage<In, Out, SourceElement> : PipelineStage<In, Out, SourceElement>
{
    let mapper: (In) -> Out
    
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, mapper: @escaping (In) -> Out)
    {
        self.mapper = mapper
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func consume(_ t: In) {
        if let nextStage = self.nextStage {
            nextStage.consume(mapper(t))
        }
    }
}

class FilterPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement>
{
    let predicate: (T) -> Bool
    
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, predicate: @escaping (T) -> Bool)
    {
        self.predicate = predicate
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func consume(_ t: T) {
        if let nextStage = self.nextStage {
            if predicate(t) {
                nextStage.consume(t)
            }
        }
    }
}

