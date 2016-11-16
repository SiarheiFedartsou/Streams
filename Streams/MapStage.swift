//
//  MapStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


class MapPipelineStage<In, Out, SourceElement> : PipelineStage<In, Out, SourceElement>
{
    let mapper: (In) -> Out
    
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, mapper: @escaping (In) -> Out) where PreviousStageType.Input == In, PreviousStageType.SourceElement == SourceElement
    {
        self.mapper = mapper
        super.init(previousStage: previousStage)
    }
    
    override func begin(size: Int) {
        nextStage?.begin(size: 0)
    }
    
    override func consume(_ t: In) {
        if let nextStage = self.nextStage {
            nextStage.consume(mapper(t))
        }
    }
    
    override func end() {
        nextStage?.end()
    }
}