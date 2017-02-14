//
//  PipelineHead.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

fileprivate final class PipelineHeadSink<T> : SinkProtocol {
    private let nextSink: UntypedSinkProtocol
    
    init(nextSink: UntypedSinkProtocol) {
        self.nextSink = nextSink
    }
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ t: T) {
        nextSink.consume(t)
    }
    
    func end() {
        nextSink.end()
    }
}

final class PipelineHead<T> : PipelineStage<T, T>
{

    
    init(source: AnySpliterator<T>, flags: StreamFlags, parallel: Bool)
    {
        super.init(previousStage: nil, stageFlags: flags)
        self.sourceSpliterator = AnySpliterator(CastingSpliterator<T, Any>(spliterator: source))
        self.sourceStage = self
        self.isParallel = parallel
    }
    
    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(PipelineHeadSink<T>(nextSink: nextSink))
    }
}
