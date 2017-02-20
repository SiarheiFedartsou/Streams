//
//  FlagModifyingStage.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 20.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

class FlagModifyingPipelineStage<T> : PipelineStage<T, T>
{
    init(previousStage: UntypedPipelineStageProtocol, flags: StreamFlagsModifiers)
    {
        super.init(previousStage: previousStage, stageFlags: flags)
    }
    
    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return nextSink
    }
}
