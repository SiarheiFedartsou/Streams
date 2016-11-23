//
//  SortedStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 16.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class SortedPipelineStage<T> : PipelineStage<T, T> where T : Comparable
{
    
    private let comparator: (T, T) -> Bool
    private var accumulator: ContiguousArray<T> = []

    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, by comparator: @escaping (T, T) -> Bool) where PreviousStageType.Output == T
    {
        self.comparator = comparator
        super.init(previousStage: previousStage)
    }
    
    override func begin(size: Int) {
        accumulator.reserveCapacity(size)
    }
    
    override func consume(_ t: T) {
        accumulator.append(t)
    }
    
    override func end() {
        accumulator.sort(by: comparator)
        nextStage?.begin(size: accumulator.count)
        for element in accumulator {
            nextStage?.consume(element)
        }
        nextStage?.end()
    }
}
