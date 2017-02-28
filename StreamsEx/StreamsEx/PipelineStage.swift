//
//  PipelineStage.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//


protocol PipelineStageProtocol {
    associatedtype SourceSpliterator : SpliteratorProtocol
    associatedtype PipelineStageIn
    associatedtype PipelineStageOut
    
    var sourceSpliterator: SourceSpliterator? { get }
    
    
}

class PipelineStage<In, Out, SourceSpliterator: SpliteratorProtocol> : Stream<Out>, PipelineStageProtocol {
    typealias PipelineStageOut = Out
    typealias PipelineStageIn = In


    let sourceSpliterator: SourceSpliterator?
    
    
    init<PreviousStage: PipelineStageProtocol & UntypedPipelineStageProtocol>(previousStage: PreviousStage?, stageFlags: StreamFlagsModifiers) where PreviousStage.SourceSpliterator == SourceSpliterator {
        self.sourceSpliterator = previousStage?.sourceSpliterator
        
        super.init()
        
        
        previousStage?.nextStage = self
        self.stageFlags = stageFlags
        
        
        self.previousStage = previousStage
        self.sourceStage = previousStage?.sourceStage
        self.unsafeSourceSpliterator = previousStage?.unsafeSourceSpliterator
        if let previousStage = previousStage {
            self.isParallel = previousStage.isParallel
            self.depth = previousStage.depth + 1
            self.combinedFlags = previousStage.combinedFlags.applying(modifiers: stageFlags)
        } else {
            self.combinedFlags = StreamFlags(modifiers: stageFlags)
        }
    }
    
    init(sourceSpliterator: SourceSpliterator, stageFlags: StreamFlagsModifiers) {
        self.sourceSpliterator = sourceSpliterator
        
        super.init()
        
        
        self.stageFlags = stageFlags
        
        
        self.previousStage = nil
        self.sourceStage = self
        self.combinedFlags = StreamFlags(modifiers: stageFlags)
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
        return AnySpliterator(WrappingSpliterator(stage: self, spliterator: unsafeSourceSpliterator!, isParallel: isParallel))
    }
    
    
    
    override func evaluate<R, TerminalOperation: TerminalOperationProtocol>(terminalOperation: TerminalOperation) -> R where TerminalOperation.Result == R {
        return isParallel ? terminalOperation.evaluateParallel(forPipelineStage: self, spliterator: spliterator()) :  terminalOperation.evaluateSequential(forPipelineStage: self, spliterator: spliterator())
    }
    
    private func spliterator() -> AnySpliterator<Any> {
        guard let sourceStage = sourceStage else { fatalError() }
        var spliterator: AnySpliterator<Any>
        if let unsafeSourceSpliterator = unsafeSourceSpliterator {
            spliterator = unsafeSourceSpliterator
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
    
    public override func map<R>(_ mapper: @escaping (Out) -> R) -> Stream<R> {
        return MapPipelineStage(previousStage: self, stageFlags: [.notSorted, .notDistinct], mapper: mapper)
    }
    
    public override func slice(_ bounds: ClosedRange<IntMax>) -> Stream<Out> {
        return SlicePipelineStage(previousStage: self, stageFlags: [], skip: bounds.lowerBound, limit: bounds.upperBound - bounds.lowerBound)
    }
    
    public override func unordered() -> Stream<T> {
        return FlagModifyingPipelineStage(previousStage: self, flags: [.notOrdered])
    }
}

extension PipelineStage {

}
