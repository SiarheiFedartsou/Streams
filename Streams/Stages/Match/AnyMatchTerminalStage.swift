//
//  AnyMatchTerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 29.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//


final class AnyMatchTerminalStage<T> : TerminalStage, SinkProtocol {
    private let predicate: (T) -> (Bool)
    private var evaluator: EvaluatorProtocol
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType,
         evaluator: EvaluatorProtocol, predicate: @escaping (T) -> Bool) where PreviousStageType.Output == T
    {
        self.evaluator = evaluator
        self.predicate = predicate
        
        previousStage.nextStage = AnySinkFactory(self)
    }
    
    func makeSink() -> AnySink<T> {
        return AnySink(self)
    }
    
    private var anyMatch: Bool = false
    
    func consume(_ t: T) {
        if predicate(t) {
            anyMatch = true
        }
    }
    
    var cancellationRequested: Bool {
        return anyMatch
    }
    
    var result: Bool {
        return self.evaluator.evaluate()!
    }
    
    func finalResult() -> Any? {
        return anyMatch
    }
}
