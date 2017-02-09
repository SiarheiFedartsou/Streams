//
//  PipelineStage.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

class PipelineStage<In, Out> : Stream<Out> {
    init(previousStage: UntypedPipelineStageProtocol?) {
        super.init()
        previousStage?.nextStage = self
        self.previousStage = previousStage
        self.sourceStage = previousStage?.sourceStage
        self.sourceSpliterator = previousStage?.sourceSpliterator
        if let previousStage = previousStage {
            self.isParallel = previousStage.isParallel
            self.depth = previousStage.depth + 1
        }
    }
}
