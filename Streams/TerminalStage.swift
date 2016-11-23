//
//  TerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol EvaluatorProtocol {
    func evaluate()
}

final class DefaultEvaluator<SourceElement> : EvaluatorProtocol {
    var source: AnySpliterator<SourceElement>
    var sourceStage: AnySink<SourceElement>
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnySink<SourceElement>) {
        self.source = source
        self.sourceStage = sourceStage
    }
    
    func evaluate() {
        sourceStage.begin(size: 0)
        while !sourceStage.cancellationRequested {
            guard let element = source.advance() else { break }
            sourceStage.consume(element)
        }
        sourceStage.end()
    }
}

protocol TerminalStage : SinkProtocol
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
