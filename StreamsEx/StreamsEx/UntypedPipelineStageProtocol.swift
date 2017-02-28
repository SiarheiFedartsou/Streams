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
    var unsafeSourceSpliterator: AnySpliterator<Any>? { get }
    
    var isStateful: Bool { get }
    var isParallel: Bool { get }
    
    var depth: Int { get set }
    
    var combinedFlags: StreamFlags { get set }
    
    func unsafeWrap(spliterator: AnySpliterator<Any>) -> AnySpliterator<Any>
    func unsafeWrap(sink: UntypedSinkProtocol) -> UntypedSinkProtocol
    func unsafeMakeSink(withNextSink: UntypedSinkProtocol) -> UntypedSinkProtocol
    func unsafeEvaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any>
    
    func evaluate<R, TerminalOperation: TerminalOperationProtocol>(terminalOperation: TerminalOperation) -> R where TerminalOperation.Result == R
}
