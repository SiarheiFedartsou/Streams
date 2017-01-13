//
//  Stream.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import Foundation

public class Stream<T> : UntypedPipelineStageProtocol {
    public func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T> {
        _abstract()
    }
    
    public func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R> {
        return MapPipelineStage(previousStage: self, mapper: mapper)
    }

    public func skip(_ size: Int) -> Stream<T> {
        _abstract()
    }
    
    public func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    {
        _abstract()
    }

    public func parallel() -> Stream<T> {
        self.isParallel = true
        return self
    }
    
    public func sequential() -> Stream<T> {
        self.isParallel = false
        return self
    }
    
    private(set) public var isParallel: Bool = false
    
    var nextStage: UntypedPipelineStageProtocol? = nil
    var previousStage: UntypedPipelineStageProtocol? = nil
    
    var sourceStage: UntypedPipelineStageProtocol? = nil
    var sourceSpliterator: UntypedSpliteratorProtocol? = nil
    
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
}