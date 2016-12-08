//
//  AllMatchTerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 29.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

final class AllMatchTerminalStageSink<T>: SinkProtocol {
    private let predicate: (T) -> (Bool)
    
    private var allMatch: Bool = true
    
    init(predicate: @escaping (T) -> Bool)
    {
        self.predicate = predicate
    }
    
    func consume(_ t: T) {
        if !predicate(t) {
            allMatch = false
        }
    }
    
    func end() {
    }
    
    var cancellationRequested: Bool {
        return !allMatch
    }
    
    func finalResult() -> Any? {
        return allMatch
    }

}

final class AllMatchTerminalStage<T> : TerminalStage {
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
        return AnySink(AllMatchTerminalStageSink(predicate: predicate))
    }
    
    
    var result: Bool { 
        return self.evaluator.evaluate()!
    }
}
