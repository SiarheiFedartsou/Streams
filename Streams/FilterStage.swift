//
//  FilterStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

final class FilterPipelineStageSink<T> : SinkProtocol
{
    private let nextSink: AnySink<T>
    private let predicate: (T) -> Bool
    
    init(nextSink: AnySink<T>, predicate: @escaping (T) -> Bool) {
        self.nextSink = nextSink
        self.predicate = predicate
    }
    
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ t: T) {
        if predicate(t) {
            nextSink.consume(t)
        }
    }
    
    func end() {
        nextSink.end()
    }
}

class FilterPipelineStage<T> : PipelineStage<T, T>
{
    let predicate: (T) -> Bool
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, predicate: @escaping (T) -> Bool) where PreviousStageType.Output == T
    {
        self.predicate = predicate
        super.init(previousStage: previousStage)
    }
    
    
    override func makeSink() -> AnySink<T> {
        return AnySink(FilterPipelineStageSink(nextSink: nextStage!.makeSink(), predicate: predicate))
    }
}
