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
        self.sourceStage = AnySink(self)
    }
    
    override func begin(size: Int) {
        nextStage?.begin(size: size)
    }
    
    override func consume(_ t: T) {
        nextStage?.consume(t)
    }
    
    override func end() {
        nextStage?.end()
    }
    
    override var cancellationRequested: Bool {
        return nextStage?.cancellationRequested ?? false
    }
    
}

class PipelineStage<In, Out, SourceElement> : SinkProtocol, StreamProtocol
{
    var nextStage: AnySink<Out>? = nil
    
    func begin(size: Int) {}
    func consume(_ t: In) {}
    func end() {}
    var cancellationRequested: Bool { return false }
    
    private var source: AnySpliterator<SourceElement>
    var sourceStage: AnySink<SourceElement>? = nil
    
    
    init(sourceStage: AnySink<SourceElement>?, source: AnySpliterator<SourceElement>)
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
        self.nextStage = AnySink(stage)
        return AnyStream(stage)
    }
    
    func map<R>(_ mapper: @escaping (Out) -> R) -> AnyStream<R>
    {
        let stage = MapPipelineStage(sourceStage: self.sourceStage!, source: source, mapper: mapper)
        self.nextStage = AnySink(stage)
        return AnyStream(stage)
    }
    
    func limit(_ size: Int) -> AnyStream<Out>
    {
        let stage = LimitPipelineStage<Out, SourceElement>(sourceStage: self.sourceStage!, source: source, size: size)
        self.nextStage = AnySink(stage)
        return AnyStream(stage)
    }
    
    func skip(_ size: Int) -> AnyStream<Out>
    {
        let stage = SkipPipelineStage<Out, SourceElement>(sourceStage: self.sourceStage!, source: source, size: size)
        self.nextStage = AnySink(stage)
        return AnyStream(stage)
    }
    
    func reduce(identity: Out, accumulator: @escaping (Out, Out) -> Out) -> Out
    {
        let stage = ReduceTerminalStage(source: source, sourceStage: sourceStage!, identity: identity, accumulator: accumulator)
        self.nextStage = AnySink(stage)
        
        return stage.evaluate()
    }
    
    func anyMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(source: source, sourceStage: sourceStage!, predicate: predicate)
        self.nextStage = AnySink(stage)
        
        return stage.evaluate()
    }
    
    func allMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(source: source, sourceStage: sourceStage!, predicate: predicate)
        self.nextStage = AnySink(stage)
        
        return stage.evaluate()
    }
    
    func noneMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(source: source, sourceStage: sourceStage!, predicate: predicate)
        self.nextStage = AnySink(stage)
        
        return stage.evaluate()
    }
    
    func forEach(_ each: @escaping (Out) -> ())
    {
        let stage = ForEachTerminalStage(source: source, sourceStage: sourceStage!, each: each)
        self.nextStage = AnySink(stage)
        
        stage.evaluate()
    }
    
    var first: Out? {
        return nil
    }
    
    var any: Out? {
        return nil
    }
}



