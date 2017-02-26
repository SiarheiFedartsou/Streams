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
        return MapPipelineStage(previousStage: self, stageFlags: [.notSorted, .notDistinct], mapper: mapper)
    }
    
    public func slice(_ bounds: ClosedRange<IntMax>) -> Stream<T> {
        return SlicePipelineStage(previousStage: self, stageFlags: [], skip: bounds.lowerBound, limit: bounds.upperBound - bounds.lowerBound)
    }
    
    public func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    {
        return evaluate(terminalOperation: ReduceTerminalOperation(identity: identity, accumulator: accumulator, combiner: accumulator))
    }

    public func reduce<U>(identity: U, accumulator: @escaping (U, T) -> U, combiner: @escaping (U, U) -> U) -> U
    {
        return evaluate(terminalOperation: ReduceTerminalOperation(identity: identity, accumulator: accumulator, combiner: combiner))
    }
    
    public func unordered() -> Stream<T> {
        return FlagModifyingPipelineStage(previousStage: self, flags: [.notOrdered])
    }
    
    public var isOrdered: Bool {
        return self.combinedFlags.contains(.ordered)
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
    
    var stageFlags = StreamFlagsModifiers()
    var combinedFlags = StreamFlags()
    
    var depth: Int = 0
    
    var isStateful: Bool {
        return false
    }
    
    
    func wrap(sink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        _abstract()
    }
    
    func makeSink(withNextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        _abstract()
    }
    
    func evaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        _abstract()
    }
    
    func evaluateParallel(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> UntypedNodeProtocol {
        _abstract()
    }
    
    
    func wrap(spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        _abstract()
    }
    
    
    
    func evaluate<R, TerminalOperation: TerminalOperationProtocol>(terminalOperation: TerminalOperation) -> R where TerminalOperation.Result == R {
        _abstract()
    }
}

extension Stream where T : Hashable {
    public func distinct() -> Stream<T> {
        return DistinctPipelineStage(previousStage: self, stageFlags: [.distinct, .notSized])
    }
}
