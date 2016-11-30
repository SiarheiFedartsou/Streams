//
//  LimitStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//


final class LimitPipelineStage<T> : PipelineStage<T, T>
{
    private var size: Int

    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType, size: Int) where PreviousStageType.Output == T
    {
        self.size = size
        super.init(previousStage: previousStage)
    }
    
    override func begin(size: Int) {
        nextStage?.begin(size: self.size)
    }
    
    override func consume(_ t: T) {
        if size > 0 {
            if let nextStage = self.nextStage {
                size -= 1
                nextStage.consume(t)
            }
        }
    }
    
    override func end() {
        nextStage?.end()
    }
    
    override var cancellationRequested: Bool {
        return size == 0 || (self.nextStage?.cancellationRequested ?? false)
    }
}
