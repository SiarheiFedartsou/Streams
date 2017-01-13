//
//  PipelineWrappingSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 27.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


final class PipelineWrappingSpliterator<T> : SpliteratorProtocol, SinkProtocol, SinkFactory {
    
    let evaluator: EvaluatorProtocol?
    
    var next: T?
    var finished = false
    
    init<PipelineStageType: PipelineStageProtocol>(pipelineStage: PipelineStageType) where PipelineStageType.Output == T
    {
        evaluator = pipelineStage.evaluator
        pipelineStage.nextStage = AnySinkFactory(self)
    }
    
    func makeSink() -> AnySink<T> {
        return AnySink(self)
    }
    
    func begin(size: Int) {
        next = nil
    }
    
    func consume(_ t: T) {
        next = t
    }
    
    func end() {
        next = nil
        finished = true
    }
    
    func finalResult() -> Any? {
        return nil
    }
    
    var cancellationRequested: Bool { return false }
    
    func advance() -> T? {
        next = nil
        while !finished && next == nil {
            evaluator?.advance()
        }
        return next
    }
    
    func forEachRemaining(_ each: (T) -> Void) {
        while let next = advance() {
            each(next)
        }
    }
    
    func split() -> AnySpliterator<T>? {
        return nil
    }
    
    var options: StreamOptions {
        return StreamOptions()
    }
    
    var estimatedSize: Int {
        return 0
    }
}
