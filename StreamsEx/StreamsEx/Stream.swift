//
//  Stream.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import Foundation

public class Stream<T> : UntypedPipelineStageProtocol {
    
    internal var _testSpliterator: WrappingSpliterator {
        return WrappingSpliterator(stage: self, spliterator: self.sourceSpliterator!, isParallel: true)
    }
    
    public func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T> {
        _abstract()
    }
    
    public func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R> {
        return MapPipelineStage(previousStage: self, mapper: mapper)
    }
    
    public func slice(_ bounds: ClosedRange<IntMax>) -> Stream<T> {
        return SlicePipelineStage(previousStage: self, skip: bounds.lowerBound, limit: bounds.upperBound - bounds.lowerBound)
    }
    
    public func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    {
        return evaluate(terminalOperation: ReduceTerminalOperation(identity: identity, accumulator: accumulator, combiner: accumulator))
    }

    public func reduce<U>(identity: U, accumulator: @escaping (U, T) -> U, combiner: @escaping (U, U) -> U) -> U
    {
        return evaluate(terminalOperation: ReduceTerminalOperation(identity: identity, accumulator: accumulator, combiner: combiner))
    }

    
    public func parallel() -> Stream<T> {
        self.isParallel = true
        return self
    }
    
    public func sequential() -> Stream<T> {
        self.isParallel = false
        return self
    }
    
    internal(set) public var isParallel: Bool = false
    
    var nextStage: UntypedPipelineStageProtocol? = nil
    var previousStage: UntypedPipelineStageProtocol? = nil
    
    var sourceStage: UntypedPipelineStageProtocol? = nil
    var sourceSpliterator: AnySpliterator<Any>? = nil
    
    var isStateful: Bool {
        return false
    }
    
    
    func wrap(sink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        var _sink = sink;
        var stage: UntypedPipelineStageProtocol? = self
        while let currentStage = stage {
            _sink = currentStage.makeSink(withNextSink: _sink)
            stage = currentStage.previousStage
        }
        return _sink;
    }
    
    func makeSink(withNextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        _abstract()
    }
    
    func evaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        return evaluateParallel(stage: stage, spliterator: spliterator).spliterator
    }
    
    func evaluateParallel(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> UntypedNodeProtocol {
        _abstract()
    }
    
    
    func wrap(spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        return AnySpliterator(WrappingSpliterator(stage: self, spliterator: sourceSpliterator!, isParallel: isParallel))
    }
    
    
    
    func evaluate<R, TerminalOperation: TerminalOperationProtocol>(terminalOperation: TerminalOperation) -> R where TerminalOperation.Result == R {
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
            while currentStage !== self, let next = nextStage {
                if next.isStateful {
                    spliterator = next.evaluateParallelLazy(stage: currentStage, spliterator: spliterator)
                }
                currentStage = next
                nextStage = next.nextStage
            }
        }
        
        return spliterator
    }
}

extension Stream where T : Hashable {
    
    public func distinct() -> Stream<T> {
        return DistinctPipelineStage(previousStage: self)
    }
    
}
