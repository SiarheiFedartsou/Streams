//
//  PipelineStage.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

class PipelineStage<In, Out> : Stream<Out> {
    
    init(previousStage: UntypedPipelineStageProtocol?, stageFlags: StreamFlagsModifiers) {
        super.init()
        previousStage?.nextStage = self
        self.stageFlags = stageFlags
        
        
        self.previousStage = previousStage
        self.sourceStage = previousStage?.sourceStage
        self.sourceSpliterator = previousStage?.sourceSpliterator
        if let previousStage = previousStage {
            self.isParallel = previousStage.isParallel
            self.depth = previousStage.depth + 1
            self.combinedFlags = previousStage.combinedFlags.applying(modifiers: stageFlags)
        } else {
            self.combinedFlags = StreamFlags(modifiers: stageFlags)
        }
    }
    
    override func wrap(sink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        var _sink = sink;
        var stage: UntypedPipelineStageProtocol? = self
        while let currentStage = stage, currentStage.depth > 0 {
            _sink = currentStage.makeSink(withNextSink: _sink)
            stage = currentStage.previousStage
        }
        return _sink;
    }
    
    override func makeSink(withNextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        _abstract()
    }
    
    override func evaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        return evaluateParallel(stage: stage, spliterator: spliterator).spliterator
    }
    
    override func evaluateParallel(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> UntypedNodeProtocol {
        _abstract()
    }
    
    
    override func wrap(spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        return AnySpliterator(WrappingSpliterator(stage: self, spliterator: sourceSpliterator!, isParallel: isParallel))
    }
    
    
    
    override func evaluate<R, TerminalOperation: TerminalOperationProtocol>(terminalOperation: TerminalOperation) -> R where TerminalOperation.Result == R {
        return isParallel ? terminalOperation.evaluateParallel(forPipelineStage: self, spliterator: spliterator()) :  terminalOperation.evaluateSequential(forPipelineStage: self, spliterator: spliterator())
    }
    
    private func spliterator() -> AnySpliterator<Any> {
        guard let sourceStage = sourceStage else { fatalError() }
        var spliterator: AnySpliterator<Any>
        if let sourceSpliterator = sourceSpliterator {
            spliterator = sourceSpliterator
        } else {
            fatalError()
        }
        
        if isParallel {
            var currentStage: UntypedPipelineStageProtocol = sourceStage
            var nextStage: UntypedPipelineStageProtocol? = sourceStage.nextStage
            var depth = 1
            while currentStage !== self, let next = nextStage {
                if next.isStateful {
                    depth = 0
                    spliterator = next.evaluateParallelLazy(stage: currentStage, spliterator: spliterator)
                }
                
                nextStage?.depth = depth
                depth += 1
                
                
                currentStage = next
                nextStage = next.nextStage
            }
        }
        
        return spliterator
    }
}
