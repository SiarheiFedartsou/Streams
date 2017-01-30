//
//  DistinctPipelineStage.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 27.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

final class DistinctPipelineStageSink<T: Hashable> : SinkProtocol {
   
    private var seen: Set<T> = Set<T>()
    
    private let nextSink: UntypedSinkProtocol
    
    init(nextSink: UntypedSinkProtocol) {
        self.nextSink = nextSink
    }
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ element: T) {
        if !seen.contains(element) {
            seen.insert(element)
            nextSink.consume(element)
        }
    }
    
    func end() {
        nextSink.end()
    }
    
    var cancellationRequested: Bool {
        return nextSink.cancellationRequested
    }
}


final class DistinctPipelineStage<T: Hashable> : PipelineStage<T, T>
{
    init(previousStage: UntypedPipelineStageProtocol)
    {
        super.init(previousStage: previousStage)
    }
    
    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(DistinctPipelineStageSink<T>(nextSink: nextSink))
    }
    
    override var isStateful: Bool {
        return true
    }
    
    override func evaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        let spliterator = CastingSpliterator<Any, T>(spliterator: stage.wrap(spliterator: spliterator))
        let distinctSpliterator = DistinctSpliterator(spliterator: AnySpliterator(spliterator))
        let castingSpliterator = CastingSpliterator<T, Any>(spliterator: AnySpliterator(distinctSpliterator))
        return AnySpliterator(castingSpliterator)
    }
    
    override func evaluateParallel(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> UntypedNodeProtocol {
       _abstract()
        //
    }
}
