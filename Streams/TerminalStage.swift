//
//  TerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol EvaluatorProtocol {
    func evaluate<T>() -> T?
    
    func advance()
}

final class DefaultEvaluator<SourceElement> : EvaluatorProtocol {
    var source: AnySpliterator<SourceElement>
    var sourceStage: AnySinkFactory<SourceElement>
    
    var sourceSink: UntypedSinkProtocol? = nil
    
    var started = false
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnySinkFactory<SourceElement>) {
        self.source = source
        self.sourceStage = sourceStage
        
    }
    
    func evaluate<T>() -> T? {
        self.sourceSink = UntypedSink(self.sourceStage.makeSink())
    
        guard let sourceSink = sourceSink else { return nil }
        

        started = true
        sourceSink.begin(size: 0)
        while !sourceSink.cancellationRequested {
            guard let element = source.advance() else { break }
            sourceSink.consume(element)
        }
        sourceSink.end()
        
        return sourceSink.finalResult() as? T
    }
    
    func advance() {
        if sourceSink == nil {
            self.sourceSink = UntypedSink(self.sourceStage.makeSink())
        }
        
        guard let sourceSink = sourceSink else { return }
        if !started {
            started = true
            sourceSink.begin(size: 0)
        }
        if !sourceSink.cancellationRequested {
            if let element = source.advance() {
                sourceSink.consume(element)
            } else {
                sourceSink.end()
            }
        } else {
           sourceSink.end()
        }
    }
}

protocol TerminalStage : SinkFactory
{
    associatedtype Result
    var result: Result { get }
}




//class TerminalStage<Result, T, SourceElement> : TerminalStageProtocol {
//    
//    func begin(size: Int) {}
//    func consume(_ t: T) {}
//    func end() {}
//    var cancellationRequested: Bool { return false }
//    
//    var nextStage: AnySink<T>? = nil
//    var source: AnySpliterator<SourceElement>
//    var sourceStage: AnySink<SourceElement>? = nil
//    
//    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == T, PreviousStageType.SourceElement == SourceElement
//    {
//        self.source = previousStage.source
//        self.sourceStage = previousStage.sourceStage
//        previousStage.nextStage = AnySink(self)
//    }
//    
//    
//    func evaluate() -> Result {
//        
//    }
//}
