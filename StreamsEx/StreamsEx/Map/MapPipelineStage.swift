//
//  MapPipelineStage.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

final class UnsafeMapPipelineStageSink<In, Out> : SinkProtocol {
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

final class MapPipelineStageSink<In, Out, NextSink: SinkProtocol> : SinkProtocol where NextSink.Consumable == Out {
    private let mapper: (In) -> (Out)
    private let nextSink: NextSink
    
    init(nextSink: NextSink, mapper: @escaping (In) -> Out)  {
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


class MapPipelineStage<In, Out, SourceSpliterator: SpliteratorProtocol, PreviousStage: PipelineStageProtocol> : PipelineStage<In, Out, SourceSpliterator, PreviousStage> where PreviousStage.PipelineStageOut == In
{
    let mapper: (In) -> Out
    
    init<UnsafePreviousStage: PipelineStageProtocol & UntypedPipelineStageProtocol>(previousStage: UnsafePreviousStage?, stageFlags: StreamFlagsModifiers, mapper: @escaping (In) -> Out) where UnsafePreviousStage.SourceSpliterator == SourceSpliterator {
        self.mapper = mapper
        super.init(previousStage: previousStage, stageFlags: stageFlags)
    }
    
    override func unsafeMakeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(UnsafeMapPipelineStageSink(nextSink: nextSink, mapper: mapper))
    }
    
    override func makeSink<NextSink: SinkProtocol>(withNextSink nextSink: NextSink) -> AnySink<PipelineStageIn> where NextSink.Consumable == Out {
        return AnySink(MapPipelineStageSink<In, Out, NextSink>(nextSink: nextSink, mapper: mapper))
    }
}
