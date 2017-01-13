//
//  UntypedPipelineStageProtocol.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

internal protocol UntypedPipelineStageProtocol : class {
    var nextStage: UntypedPipelineStageProtocol? { get set }
    var previousStage: UntypedPipelineStageProtocol? { get }
    
    var sourceStage: UntypedPipelineStageProtocol? { get }
    var sourceSpliterator: UntypedSpliteratorProtocol? { get }
    
    var isStateful: Bool { get }
    
    func wrap(sink: UntypedSinkProtocol) -> UntypedSinkProtocol
    func makeSink(withNextSink: UntypedSinkProtocol) -> UntypedSinkProtocol
    
}
