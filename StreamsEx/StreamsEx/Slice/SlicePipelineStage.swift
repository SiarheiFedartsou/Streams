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


final class SlicePipelineStage<T> : PipelineStage<T, T>
{
    private let bounds: ClosedRange<IntMax>
    
    
    init(previousStage: UntypedPipelineStageProtocol, bounds: ClosedRange<IntMax>)
    {
        self.bounds = bounds
        super.init(previousStage: previousStage)
    }
    
    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(SlicePipelineStageSink<T>(nextSink: nextSink, skip: bounds.lowerBound, limit: bounds.upperBound - bounds.lowerBound))
    }
    
    override var isStateful: Bool {
        return true
    }
}
