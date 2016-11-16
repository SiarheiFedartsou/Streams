//
//  FilterStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class FilterPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement>
{
    let predicate: (T) -> Bool
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, predicate: @escaping (T) -> Bool) where PreviousStageType.Input == T, PreviousStageType.SourceElement == SourceElement
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
