//
//  DistinctStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 23.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class DistinctPipelineStage<T> : PipelineStage<T, T> where T : Hashable
{
    
    var seen: Set<T> = Set<T>()
    
    override init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == T
    {
        super.init(previousStage: previousStage)
    }
    
    override func begin(size: Int) {
        nextStage?.begin(size: size)
    }
    
    override func consume(_ t: T) {
        if !seen.contains(t) {
            seen.insert(t)
            nextStage?.consume(t)
        }
    }
    
    override func end() {
        nextStage?.end()
    }
}
