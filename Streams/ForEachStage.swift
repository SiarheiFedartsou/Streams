//
//  ForEachStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

final class ForEachTerminalStageSink<T> : SinkProtocol {
    private let each: (T) -> ()
    
    init(each: @escaping (T) -> ()) {
        self.each = each
    }
    
    func consume(_ t: T) {
        each(t)
    }
    
    func finalResult() -> Any? {
        return ()
    }
}

class ForEachTerminalStage<T> : TerminalStage {
    
    private let each: (T) -> ()
    private var evaluator: EvaluatorProtocol
    
    init(evaluator: EvaluatorProtocol, each: @escaping (T) -> ())
    {
        self.evaluator = evaluator
        self.each = each
    }
    
    func makeSink() -> AnySink<T> {
        return AnySink(ForEachTerminalStageSink(each: each))
    }
    
    var result: Void {
        return evaluator.evaluate()!
    }

}
