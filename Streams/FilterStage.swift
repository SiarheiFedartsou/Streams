//
//  FilterStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class FilterPipelineStage<T> : PipelineStage<T, T>
{
    let predicate: (T) -> Bool
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, predicate: @escaping (T) -> Bool) where PreviousStageType.Output == T
    {
        self.predicate = predicate
        super.init(previousStage: previousStage)
    }
    
    
    override func begin(size: Int) {
        nextStage?.begin(size: 0)
    }
    
    override func consume(_ t: T) {
        if let nextStage = self.nextStage {
            if predicate(t) {
                nextStage.consume(t)
            }
        }
    }
    
    override func end() {
        nextStage?.end()
    }
}
