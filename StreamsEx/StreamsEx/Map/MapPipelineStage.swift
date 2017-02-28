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


class MapPipelineStage<In, Out, SourceSpliterator: SpliteratorProtocol> : PipelineStage<In, Out, SourceSpliterator>
{
    let mapper: (In) -> Out
    
    init<PreviousStage: PipelineStageProtocol & UntypedPipelineStageProtocol>(previousStage: PreviousStage?, stageFlags: StreamFlagsModifiers, mapper: @escaping (In) -> Out) where PreviousStage.SourceSpliterator == SourceSpliterator {
        self.mapper = mapper
        super.init(previousStage: previousStage, stageFlags: stageFlags)
    }
    
    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(MapPipelineStageSink(nextSink: nextSink, mapper: mapper))
    }
}
