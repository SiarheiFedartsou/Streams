//
//  SkipStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

final class SkipPipelineStageSink<T> : SinkProtocol
{
    private let nextSink: AnySink<T>
    private let sizeToSkip: Int
    
    private var skipped: Int = 0
    
    
    init(nextSink: AnySink<T>, sizeToSkip: Int) {
        self.nextSink = nextSink
        self.sizeToSkip = sizeToSkip
    }
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ t: T) {
        if (skipped == sizeToSkip) {
            nextSink.consume(t)
        } else {
            skipped += 1
        }
    }
    
    func end() {
        nextSink.end()
    }
    
    func finalResult() -> Any? {
        return nextSink.finalResult()
    }
    
    var cancellationRequested: Bool {
        return nextSink.cancellationRequested
    }
}

class SkipPipelineStage<T> : PipelineStage<T, T>
{
    let sizeToSkip: Int
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, size: Int) where PreviousStageType.Output == T
    {
        self.sizeToSkip = size
        super.init(previousStage: previousStage)
    }
    
    override func makeSink() -> AnySink<T> {
        return AnySink(SkipPipelineStageSink(nextSink: nextStage!.makeSink(), sizeToSkip: sizeToSkip))
    }
}
