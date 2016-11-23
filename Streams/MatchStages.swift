//
//  MatchStages.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class NoneMatchTerminalStage<T> : TerminalStage {
    private let predicate: (T) -> (Bool)
    private var evaluator: EvaluatorProtocol
    
    init(evaluator: EvaluatorProtocol, predicate: @escaping (T) -> Bool)
    {
        self.evaluator = evaluator
        self.predicate = predicate
    }
    
    private var noneMatch: Bool = false
    
    func consume(_ t: T) {
        if !predicate(t) {
            noneMatch = true
        }
    }
    
    var result: Bool {
        self.evaluator.evaluate()
        return noneMatch
    }
}
