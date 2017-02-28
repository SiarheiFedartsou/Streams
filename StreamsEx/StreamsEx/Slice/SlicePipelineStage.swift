//
//  SlicePipelineStage.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 15.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import Foundation

final class SlicePipelineStageSink<T> : SinkProtocol {
    private var remainingToSkip: IntMax
    private var remainingToConsume: IntMax
    
    private let nextSink: UntypedSinkProtocol
    
    init(nextSink: UntypedSinkProtocol, skip: IntMax, limit: IntMax) {
        self.nextSink = nextSink
        self.remainingToSkip = skip
        self.remainingToConsume = limit
    }
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ element: T) {
        if remainingToSkip == 0 {
            if remainingToConsume > 0 {
                nextSink.consume(element)
                remainingToConsume -= 1
            }
        } else {
            remainingToSkip -= 1
        }
    }
    
    func end() {
        nextSink.end()
    }
    
    var cancellationRequested: Bool {
        return remainingToConsume == 0 || nextSink.cancellationRequested
    }
}


final class SlicePipelineStage<T, SourceSpliterator: SpliteratorProtocol> : PipelineStage<T, T, SourceSpliterator>
{
    private let skip: IntMax
    private let limit: IntMax
    
    
    init<PreviousStage: PipelineStageProtocol & UntypedPipelineStageProtocol>(previousStage: PreviousStage?, stageFlags: StreamFlagsModifiers, skip: IntMax, limit: IntMax) where PreviousStage.SourceSpliterator == SourceSpliterator {
        self.skip = skip
        self.limit = limit
        super.init(previousStage: previousStage, stageFlags: stageFlags)
    }

    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(SlicePipelineStageSink<T>(nextSink: nextSink, skip: skip, limit: limit))
    }
    
    override var isStateful: Bool {
        return true
    }
    
    private func sliceFence(fromSkip skip: IntMax, limit: IntMax) -> IntMax {
        let sliceFence = limit >= 0 ? skip + limit : IntMax.max
        return sliceFence >= 0 ? sliceFence : IntMax.max
    }
    
    override func unsafeEvaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        let spliterator = AnySpliterator(CastingSpliterator<Any, T>(spliterator: stage.wrap(spliterator: spliterator)))
        let sliceSpliterator = SliceSpliterator(spliterator: spliterator, sliceOrigin: skip, sliceFence: sliceFence(fromSkip: skip, limit: limit))
        
        let castingSpliterator = CastingSpliterator<T, Any>(spliterator: AnySpliterator(sliceSpliterator))
        return AnySpliterator(castingSpliterator)
    }
}
