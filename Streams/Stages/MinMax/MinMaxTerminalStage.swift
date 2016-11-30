//
//  MinMaxTerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 29.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


final class MinMaxTerminalStage<T> : TerminalStage, SinkProtocol {
    private let comparator: (T, T) -> (Bool)
    private var evaluator: EvaluatorProtocol
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType,
         evaluator: EvaluatorProtocol, comparator: @escaping (T, T) -> Bool) where PreviousStageType.Output == T
    {
        self.evaluator = evaluator
        self.comparator = comparator
        
        previousStage.nextStage = AnySinkFactory(self)
    }
    
    func makeSink() -> AnySink<T> {
        return AnySink(self)
    }
    
    private var possibleResult: T? = nil
    
    func consume(_ element: T) {
        guard let possibleResult = possibleResult else {
            self.possibleResult = element
            return
        }
        
        if comparator(element, possibleResult) {
            self.possibleResult = element
        }
    }
    
    var result: T? {
        self.evaluator.evaluate()
        return possibleResult
    }
}
