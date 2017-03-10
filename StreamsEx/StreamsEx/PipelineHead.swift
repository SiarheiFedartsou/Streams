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

final class DummyPreviousPipelineStage<T> : PipelineStageProtocol {
    var sourceSpliterator: AnySpliterator<T>? = nil
    
    func evaluateParallelLazy<Stage: PipelineStageProtocol, Spliterator: SpliteratorProtocol>(stage: Stage, spliterator: Spliterator) -> AnySpliterator<T> where Spliterator.Element == T {
        _abstract()
    }
    
    func wrap<Spliterator: SpliteratorProtocol>(spliterator: Spliterator) -> AnySpliterator<T> where Spliterator.Element == T {
        _abstract()
    }
    
    func wrap<Sink: SinkProtocol>(sink: Sink) -> AnySink<T> where Sink.Consumable == T {
        _abstract()
    }
    
    func makeSink<NextSink: SinkProtocol>(withNextSink nextSink: NextSink) -> AnySink<T> where NextSink.Consumable == T {
        _abstract()
    }
}

final class PipelineHead<T, SourceSpliterator: SpliteratorProtocol> : PipelineStage<T, T, SourceSpliterator, DummyPreviousPipelineStage<T>>  where SourceSpliterator.Element == T
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
