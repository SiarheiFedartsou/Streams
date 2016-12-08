//
//  DistinctStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 23.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

final class DistinctPipelineStageSink<T: Hashable>: SinkProtocol {
    private let nextSink: AnySink<T>
    
    init(nextSink: AnySink<T>) {
        self.nextSink = nextSink
    }
    
    private var seen: Set<T> = Set<T>()
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ t: T) {
        if !seen.contains(t) {
            seen.insert(t)
            nextSink.consume(t)
        }
    }
    
    func end() {
        nextSink.end()
    }
    
    func finalResult() -> Any? {
        return nextSink.finalResult()
    }
    
}

final class DistinctPipelineStage<T> : PipelineStage<T, T> where T : Hashable
{

    override init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == T
    {
        super.init(previousStage: previousStage)
    }
    
    override func makeSink() -> AnySink<T> {
        return AnySink(DistinctPipelineStageSink(nextSink: nextStage!.makeSink()))
    }
}
