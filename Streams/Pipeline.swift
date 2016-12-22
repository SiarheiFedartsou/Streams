//
//  Pipeline.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

internal protocol UntypedPipelineStageProtocol : class {
    var nextStage: UntypedPipelineStageProtocol? { get }
    weak var previousStage: UntypedPipelineStageProtocol? { get }
    
    var sourceStage: UntypedPipelineStageProtocol { get }
    var sourceSpliterator: UntypedSpliteratorProtocol { get }
    
    var isStateful: Bool { get }
    var sinkFactory: UntypedSinkFactoryProtocol { get }
}

internal protocol PipelineStageProtocol : class {
    associatedtype Output
    
    var nextStage: AnySinkFactory<Output>? { get set }
    var evaluator: EvaluatorProtocol? { get }
    var characteristics: StreamOptions { get }
    var isParallel: Bool { get }
}


final class PipelineHead<T> : PipelineStage<T, T>
{
    init(source: AnySpliterator<T>, characteristics: StreamOptions, parallel: Bool)
    {
        super.init(evaluator: nil, characteristics: characteristics, parallel: parallel)
        self.evaluator = DefaultEvaluator(source: source, sourceStage: AnySinkFactory(self))
    }
    
    override func makeSink() -> AnySink<T> {
        return AnySink(ChainedSink(nextSink: nextStage!.makeSink()))
    }
    
}

class PipelineStage<In, Out> : Stream<Out>, SinkFactory
{
    init(evaluator: EvaluatorProtocol?, characteristics: StreamOptions, parallel: Bool)
    {
        super.init(characteristics: characteristics, parallel: parallel)
        self.evaluator = evaluator
    }
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == In
    {
        super.init(characteristics: previousStage.characteristics, parallel: previousStage.isParallel)
        self.evaluator = previousStage.evaluator
        previousStage.nextStage = AnySinkFactory(self)
    }
    
    override var spliterator: AnySpliterator<Out> {
        return AnySpliterator(PipelineWrappingSpliterator(pipelineStage: self))
    }
    
    override func reduce(identity: Out, accumulator: @escaping (Out, Out) -> Out) -> Out
    {
        let stage = ReduceTerminalStage(evaluator: evaluator!, identity: identity, accumulator: accumulator)
        self.nextStage = AnySinkFactory(stage)
        return stage.result
    }
    
    override func forEach(_ each: @escaping (Out) -> ())
    {
        let stage = ForEachTerminalStage(evaluator: evaluator!, parallel: isParallel, each: each)
        self.nextStage = AnySinkFactory(stage)
        
        return stage.result
    }
    
    override var first: Out? {
        return nil
    }
    
    override var any: Out? {
        return nil
    }
    
    func makeSink() -> AnySink<In> {
        _abstract()
    }
    
    var isStateful: Bool {
        return false
    }
}



