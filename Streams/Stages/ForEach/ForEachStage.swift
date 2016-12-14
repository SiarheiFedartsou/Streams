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

final class ForEachTerminalStage<T> : TerminalStage {
    
    private let each: (T) -> ()
    private var evaluator: EvaluatorProtocol
    
    private let isParallel: Bool
    
    init(evaluator: EvaluatorProtocol, parallel: Bool, each: @escaping (T) -> ())
    {
        self.evaluator = evaluator
        self.each = each
        self.isParallel = parallel
    }
    
    func makeSink() -> AnySink<T> {
        return AnySink(ForEachTerminalStageSink(each: each))
    }
    
    var result: Void {
        if isParallel {
            return ForEachTask(spliterator: evaluator.makeSpliterator(), sink: evaluator.makeSink(), each: each).invoke()
        } else {
            return evaluator.evaluate()!
        }
    }

}
