//
//  FlattenStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 30.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

final class FlattenPipelineStage<In: StreamProtocol, Out> : PipelineStage<In, Out> where In.T == Out
{
    override init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType) where PreviousStageType.Output == In
    {
        super.init(previousStage: previousStage)
    }
    
    override func begin(size: Int) {
        nextStage?.begin(size: size)
    }
    
    override func consume(_ element: In) {
        var spliterator = element.spliterator
        while let next = spliterator.advance() {
            nextStage?.consume(next)
        }
    }
    
    override func end() {
        nextStage?.end()
    }
}
