//
//  ReduceStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class ReduceTerminalStage<T> : TerminalStage, SinkProtocol {
    private var evaluator: EvaluatorProtocol
    
    
    private var identity: T
    private var accumulator: (T, T) -> T
    
    init(evaluator: EvaluatorProtocol, identity: T, accumulator: @escaping (T, T) -> T)
    {
        self.evaluator = evaluator
        self.identity = identity
        self.accumulator = accumulator
    }
    
    func makeSink() -> AnySink<T> {
        return AnySink(self)
    }
    
    func consume(_ t: T) {
        identity = accumulator(identity, t)
    }
    
    var result: T {
        self.evaluator.evaluate()
        return identity
    }
}
