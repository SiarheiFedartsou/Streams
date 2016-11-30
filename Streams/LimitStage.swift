//
//  LimitStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

final class LimitPipelineStageSink<T> : SinkProtocol {
    private var size: Int
    let nextSink: AnySink<T>
    
    init(nextSink: AnySink<T>, size: Int) {
        self.nextSink = nextSink
        self.size = size
    }
    
    func begin(size: Int) {
        nextSink.begin(size: self.size)
    }
    
    func consume(_ t: T) {
        if size > 0 {
            size -= 1
            nextSink.consume(t)
        }
    }
    
    func end() {
        nextSink.end()
    }
    
    var cancellationRequested: Bool {
        return size == 0 || nextSink.cancellationRequested
    }
    
}

final class LimitPipelineStage<T> : PipelineStage<T, T>
{
    private var size: Int

    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, size: Int) where PreviousStageType.Output == T
    {
        self.size = size
        super.init(previousStage: previousStage)
    }
    
    override func makeSink() -> AnySink<T> {
        return AnySink(LimitPipelineStageSink(nextSink: nextStage!.makeSink(), size: size))
    }
}
