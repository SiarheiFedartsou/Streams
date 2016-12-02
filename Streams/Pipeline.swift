//
//  Pipeline.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


internal protocol PipelineStageProtocol : class {
    associatedtype Output
    
    var nextStage: AnySinkFactory<Output>? { get set }
    var evaluator: EvaluatorProtocol? { get }
    var characteristics: StreamOptions { get }
}


class PipelineHead<T> : PipelineStage<T, T>
{
    init(source: AnySpliterator<T>, characteristics: StreamOptions)
    {
        super.init(evaluator: nil, characteristics: characteristics)
        self.evaluator = DefaultEvaluator(source: source, sourceStage: AnySinkFactory(self))
    }
    
//    override func begin(size: Int) {
//        nextStage?.begin(size: size)
//    }
//    
//    override func consume(_ t: T) {
//        nextStage?.consume(t)
//    }
//    
//    override func end() {
//        nextStage?.end()
//    }
//    
//    override var cancellationRequested: Bool {
//        return nextStage?.cancellationRequested ?? false
//    }
    
    override func makeSink() -> AnySink<T> {
        return AnySink(ChainedSink(nextSink: nextStage!.makeSink()))
    }
    
}

class PipelineStage<In, Out> : Stream<Out>, SinkFactory
{
//    func begin(size: Int) {}
//    func consume(_ t: In) {}
//    func end() {}
//    var cancellationRequested: Bool { return false }
//    
    init(evaluator: EvaluatorProtocol?, characteristics: StreamOptions)
    {
        super.init(characteristics: characteristics)
        self.evaluator = evaluator
    }
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == In
    {
        super.init(characteristics: previousStage.characteristics)
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
        let stage = ForEachTerminalStage(evaluator: evaluator!, each: each)
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
}



