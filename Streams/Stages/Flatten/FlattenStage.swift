//
//  FlattenStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 30.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

final class FlattenPipelineStageSink<In: StreamProtocol, Out> : SinkProtocol  where In.T == Out
{
    private let nextSink: AnySink<Out>
    
    init(nextSink: AnySink<Out>) {
        self.nextSink = nextSink
    }
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ element: In) {
        var spliterator = element.spliterator
        while let next = spliterator.advance() {
            nextSink.consume(next)
        }
    }
    
    func end() {
        nextSink.end()
    }
    
    func finalResult() -> Any? {
        return nextSink.finalResult()
    }
}

final class FlattenPipelineStage<In: StreamProtocol, Out> : PipelineStage<In, Out> where In.T == Out
{
    override init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == In
    {
        super.init(previousStage: previousStage)
    }
    
    override func makeSink() -> AnySink<In> {
        return AnySink(FlattenPipelineStageSink(nextSink: nextStage!.makeSink()))
    }
}
