//
//  MapPipelineStage.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

final class MapPipelineStageSink<In, Out> : SinkProtocol {
    private let mapper: (In) -> (Out)
    private let nextSink: UntypedSinkProtocol
    
    init(nextSink: UntypedSinkProtocol, mapper: @escaping (In) -> Out) {
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
    
    
    init(previousStage: UntypedPipelineStageProtocol, mapper: @escaping (In) -> Out)
    {
        self.mapper = mapper
        super.init(previousStage: previousStage)
    }
    
    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(MapPipelineStageSink(nextSink: nextSink, mapper: mapper))
    }
}
