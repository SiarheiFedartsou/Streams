//
//  Pipeline.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol PipelineStageProtocol : class, SinkProtocol {
    associatedtype SourceElement
    associatedtype Input
    
    var nextStage: AnySink<Input>? { get set }
    var source: AnySpliterator<SourceElement> { get set }
    var sourceStage: AnySink<SourceElement>? { get set }
}

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

class PipelineStage<In, Out, SourceElement> : StreamProtocol, PipelineStageProtocol
{
    
    func begin(size: Int) {}
    func consume(_ t: In) {}
    func end() {}
    var cancellationRequested: Bool { return false }
    
    var nextStage: AnySink<Out>? = nil
    var source: AnySpliterator<SourceElement>
    var sourceStage: AnySink<SourceElement>? = nil
    
    init(sourceStage: AnySink<SourceElement>?, source: AnySpliterator<SourceElement>)
    {
        self.source = source
        self.sourceStage = sourceStage
    }
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Input == In, PreviousStageType.SourceElement == SourceElement
    {
        self.source = previousStage.source
        self.sourceStage = previousStage.sourceStage
        previousStage.nextStage = AnySink(self)
    }
    
    var spliterator: AnySpliterator<Out> {
        return [Out]().spliterator
    }
    
    func filter(_ predicate: @escaping (Out) -> Bool) -> AnyStream<Out>
    {
        return AnyStream(FilterPipelineStage(previousStage: self, predicate: predicate))
    }
    
    func map<R>(_ mapper: @escaping (Out) -> R) -> AnyStream<R>
    {
        return AnyStream(MapPipelineStage(previousStage: self, mapper: mapper))
    }
    
    func limit(_ size: Int) -> AnyStream<Out>
    {
        return AnyStream(LimitPipelineStage<Out, SourceElement>(previousStage: self, size: size))
    }
    
    func skip(_ size: Int) -> AnyStream<Out>
    {
        return AnyStream(SkipPipelineStage<Out, SourceElement>(previousStage: self, size: size))
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



