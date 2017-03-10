//
//  FlagModifyingStage.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 20.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

class FlagModifyingPipelineStage<T, SourceSpliterator: SpliteratorProtocol, PreviousStage: PipelineStageProtocol> : PipelineStage<T, T, SourceSpliterator, PreviousStage> where PreviousStage.PipelineStageOut == T
{
    init<UnsafePreviousStage: PipelineStageProtocol & UntypedPipelineStageProtocol>(previousStage: UnsafePreviousStage?, flags: StreamFlagsModifiers) where UnsafePreviousStage.SourceSpliterator == SourceSpliterator
    {
        super.init(previousStage: previousStage, stageFlags: flags)
    }
    
    override func unsafeMakeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return nextSink
    }
}
