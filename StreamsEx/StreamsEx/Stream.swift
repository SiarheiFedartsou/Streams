//
//  Stream.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import Foundation

public class Stream<T> : UntypedPipelineStageProtocol {
    
    internal var _testSpliterator: UnsafeWrappingSpliterator {
        return UnsafeWrappingSpliterator(stage: self, spliterator: self.unsafeSourceSpliterator!, isParallel: true)
    }
    
    public func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T> {
        _abstract()
    }
    
    public func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R> {
        _abstract()
    }
    
    public func slice(_ bounds: ClosedRange<IntMax>) -> Stream<T> {
        _abstract()
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
        _abstract()
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
    var unsafeSourceSpliterator: AnySpliterator<Any>? = nil
    
    var stageFlags = StreamFlagsModifiers()
    var combinedFlags = StreamFlags()
    
    var depth: Int = 0
    
    var isStateful: Bool {
        return false
    }
    
    
    func unsafeWrap(sink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        _abstract()
    }
    
    func unsafeMakeSink(withNextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        _abstract()
    }
    
    func unsafeEvaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        _abstract()
    }
    
    func evaluateParallel(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> UntypedNodeProtocol {
        _abstract()
    }
    
    
    func unsafeWrap(spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        _abstract()
    }
    
    
    
    func evaluate<R, TerminalOperation: TerminalOperationProtocol>(terminalOperation: TerminalOperation) -> R where TerminalOperation.Result == R {
        _abstract()
    }
}

extension Stream where T : Hashable {
    public func distinct() -> Stream<T> {
        _abstract()
        //return DistinctPipelineStage(previousStage: self, stageFlags: [.distinct, .notSized])
    }
}
