//
//  Pipeline.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol PipelineStageProtocol : class {
    associatedtype Output
    
    var nextStage: AnySink<Output>? { get set }
    var evaluator: EvaluatorProtocol? { get }
}

class PipelineHead<T> : PipelineStage<T, T>
{
    init(source: AnySpliterator<T>)
    {
        super.init(evaluator: nil)
        self.evaluator = DefaultEvaluator(source: source, sourceStage: AnySink(self))
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

class PipelineStage<In, Out> : StreamProtocol, PipelineStageProtocol, SinkProtocol
{
    var nextStage: AnySink<Out>? = nil
    
    
    var evaluator: EvaluatorProtocol?
    
    func begin(size: Int) {}
    func consume(_ t: In) {}
    func end() {}
    var cancellationRequested: Bool { return false }
    

    init(evaluator: EvaluatorProtocol?)
    {
        self.evaluator = evaluator
    }
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == In
    {
        self.evaluator = previousStage.evaluator
        previousStage.nextStage = AnySink(self)
    }
    
    var spliterator: AnySpliterator<Out> {
        return [Out]().spliterator
    }
    
    func reduce(identity: Out, accumulator: @escaping (Out, Out) -> Out) -> Out
    {
        let stage = ReduceTerminalStage(evaluator: evaluator!, identity: identity, accumulator: accumulator)
        self.nextStage = AnySink(stage)
        return stage.result
    }
    
    func anyMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(evaluator: evaluator!, predicate: predicate)
        self.nextStage = AnySink(stage)
        return stage.result
    }
    
    func allMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(evaluator: evaluator!, predicate: predicate)
        self.nextStage = AnySink(stage)
        return stage.result
    }
    
    func noneMatch(_ predicate: @escaping (Out) -> Bool) -> Bool
    {
        let stage = NoneMatchTerminalStage(evaluator: evaluator!, predicate: predicate)
        self.nextStage = AnySink(stage)
        return stage.result
    }
    
    func forEach(_ each: @escaping (Out) -> ())
    {
        let stage = ForEachTerminalStage(evaluator: evaluator!, each: each)
        self.nextStage = AnySink(stage)
        
        return stage.result
    }
    
    var first: Out? {
        return nil
    }
    
    var any: Out? {
        return nil
    }
}



