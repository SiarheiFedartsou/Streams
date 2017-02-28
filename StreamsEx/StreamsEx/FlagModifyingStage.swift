//
//  FlagModifyingStage.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 20.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

class FlagModifyingPipelineStage<T, SourceSpliterator: SpliteratorProtocol> : PipelineStage<T, T, SourceSpliterator>
{
    init<PreviousStage: PipelineStageProtocol & UntypedPipelineStageProtocol>(previousStage: PreviousStage?, flags: StreamFlagsModifiers) where PreviousStage.SourceSpliterator == SourceSpliterator
    {
        super.init(previousStage: previousStage, stageFlags: flags)
    }
    
    override func makeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return nextSink
    }
}
