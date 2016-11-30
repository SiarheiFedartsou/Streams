//
//  MapStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

final class MapPipelineStageSink<In, Out> : SinkProtocol {
    private let mapper: (In) -> (Out)
    private let nextSink: AnySink<Out>
    
    init(nextSink: AnySink<Out>, mapper: @escaping (In) -> Out) {
        self.nextSink = nextSink
        self.mapper = mapper
    }
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ t: In) {
        nextSink.consume(mapper(t))
    }
    
    func end() {
        nextSink.end()
    }
}

class MapPipelineStage<In, Out> : PipelineStage<In, Out>
{
    let mapper: (In) -> Out
    
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, mapper: @escaping (In) -> Out) where PreviousStageType.Output == In
    {
        self.mapper = mapper
        super.init(previousStage: previousStage)
    }
    
    override func makeSink() -> AnySink<In> {
        return AnySink(MapPipelineStageSink(nextSink: nextStage!.makeSink(), mapper: mapper))
    }
}
