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

final class PipelineHead<T, SourceSpliterator: SpliteratorProtocol> : PipelineStage<T, T, SourceSpliterator>  where SourceSpliterator.Element == T
{

    init(source: SourceSpliterator, flags: StreamFlagsModifiers, parallel: Bool)
    {
        super.init(sourceSpliterator: source, stageFlags: flags)
        self.unsafeSourceSpliterator = AnySpliterator(CastingSpliterator<SourceSpliterator.Element, Any>(spliterator: AnySpliterator(source)))
        self.sourceStage = self
        self.isParallel = parallel
    }
    
    override func unsafeMakeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(PipelineHeadSink<T>(nextSink: nextSink))
    }
}
