//
//  SortedStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 16.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

final class SortedPipelineStageSink<T> : SinkProtocol {
    private let nextSink: AnySink<T>
    private let comparator: (T, T) -> Bool
    
    private var accumulator: ContiguousArray<T> = []
    
    init(nextSink: AnySink<T>, comparator: @escaping (T, T) -> Bool) {
        self.nextSink = nextSink
        self.comparator = comparator
    }
    
    func begin(size: Int) {
        accumulator.reserveCapacity(size)
    }
    
    func consume(_ t: T) {
        accumulator.append(t)
    }
    
    func end() {
        accumulator.sort(by: comparator)
        nextSink.begin(size: accumulator.count)
        for element in accumulator {
            nextSink.consume(element)
        }
        nextSink.end()
    }
}

class SortedPipelineStage<T> : PipelineStage<T, T> where T : Comparable
{
    
    private let comparator: (T, T) -> Bool
    private var accumulator: ContiguousArray<T> = []

    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, by comparator: @escaping (T, T) -> Bool) where PreviousStageType.Output == T
    {
        self.comparator = comparator
        super.init(previousStage: previousStage)
    }
    
    
    override func makeSink() -> AnySink<T> {
        return AnySink(SortedPipelineStageSink(nextSink: nextStage!.makeSink(), comparator: comparator))
    }
    }
