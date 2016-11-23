//
//  ForEachStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class ForEachTerminalStage<T> : TerminalStage {
    
    private let each: (T) -> ()
    private var evaluator: EvaluatorProtocol
    
    init(evaluator: EvaluatorProtocol, each: @escaping (T) -> ())
    {
        self.evaluator = evaluator
        self.each = each
    }
    
    func consume(_ t: T) {
        each(t)
    }
    
    var result: Void {
        evaluator.evaluate()
        return ()
    }

}
