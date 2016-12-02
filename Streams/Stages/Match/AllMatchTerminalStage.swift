//
//  AllMatchTerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 29.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

protocol Resulting {
    associatedtype Result
    var result: Result { get }
}


final class AllMatchTerminalStageSink<T>: SinkProtocol {
    private let predicate: (T) -> (Bool)
    private let onResult: (Bool) -> ()
    
    private var allMatch: Bool = true
    
    init(predicate: @escaping (T) -> Bool, onResult: @escaping (Bool) -> ())
    {
        self.predicate = predicate
        self.onResult = onResult
    }
    
    func consume(_ t: T) {
        if !predicate(t) {
            allMatch = false
        }
    }
    
    func end() {
        onResult(allMatch)
    }
    
    var cancellationRequested: Bool {
        return !allMatch
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
        return AnySink(AllMatchTerminalStageSink(predicate: predicate, onResult:  {
            self._result = $0
        }))
    }
    
    private var _result: Bool = true
    

    
    var result: Bool { 
        self.evaluator.evaluate()
        return _result
    }
}
