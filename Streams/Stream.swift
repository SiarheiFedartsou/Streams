//
//  Stream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.10.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation
import Swift

public protocol StreamProtocol {
    associatedtype T
    var spliterator: AnySpliterator<T> { get }
  
    var count: Int { get }
    
    
    func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T>
    func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R>
    
    func flatMap<R: StreamProtocol>(_ mapper: @escaping (T) -> R) -> Stream<R.T>
    
    func limit(_ size: Int) -> Stream<T>
    func skip(_ size: Int) -> Stream<T>
    
    func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    
    func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    
    func forEach(_ each: @escaping (T) -> ())
    var first: T? { get }
    var any: T? { get }
}

public class Stream<T> : PipelineStageProtocol, StreamProtocol {
    var nextStage: AnySink<T>?
    var evaluator: EvaluatorProtocol?
    
    let characteristics: StreamOptions
    
    init(characteristics: StreamOptions) {
        self.characteristics = characteristics
    }
    
    public var spliterator: AnySpliterator<T> {
        _abstract()
    }
    
    public func filter(_ predicate: @escaping (T) -> Bool) -> Stream<T>
    {
        return FilterPipelineStage(previousStage: self, predicate: predicate)
    }
    
    public func map<R>(_ mapper: @escaping (T) -> R) -> Stream<R>
    {
        return MapPipelineStage<T, R>(previousStage: self, mapper: mapper)
    }
    
    
    public func flatMap<R: StreamProtocol>(_ mapper: @escaping (T) -> R) -> Stream<R.T> {
        return self.map(mapper).flatten()
    }
    
    public func limit(_ size: Int) -> Stream<T>
    {
        return LimitPipelineStage<T>(previousStage: self, size: size)
    }
    
    public func skip(_ size: Int) -> Stream<T>
    {
        return SkipPipelineStage<T>(previousStage: self, size: size)
    }
    
    public func reduce(identity: T, accumulator: @escaping (T, T) -> T) -> T
    {
        _abstract()
    }
    
    public func anyMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    {
        let stage = AnyMatchTerminalStage(previousStage: self, evaluator: evaluator!, predicate: predicate)
        return stage.result
    }
    
    public func allMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    {
        let stage = AllMatchTerminalStage(previousStage: self, evaluator: evaluator!, predicate: predicate)
        return stage.result
    }
    
    public func noneMatch(_ predicate: @escaping (T) -> Bool) -> Bool
    {
        return !anyMatch(predicate)
    }
    
    public func forEach(_ each: @escaping (T) -> ())
    {
        _abstract()
    }
    
    public var first: T?
    {
        _abstract()
    }
    
    public var any: T?
    {
        _abstract()
    }
    
    public var count: Int {
        return map({ _ in 1 }).sum()
    }
}

public extension Stream where T : Comparable {
    func sorted() -> Stream<T> {
        return SortedPipelineStage(previousStage: self, by: <)
    }
    
    func sorted(by comparator: @escaping (T, T) -> Bool) -> Stream<T> {
        return SortedPipelineStage(previousStage: self, by: comparator)
    }
}

public extension Stream where T : Comparable {
    func max() -> T? {
        return max(by: >)
    }
    
    func max(by comparator: @escaping (T, T) -> Bool) -> T? {
        return MinMaxTerminalStage(previousStage: self, evaluator: evaluator!, comparator: comparator).result
    }
    
    func min() -> T? {
        return MinMaxTerminalStage(previousStage: self, evaluator: evaluator!, comparator: <).result
    }
    
    func min(by comparator: @escaping (T, T) -> Bool) -> T? {
        let invertedComparator = { !comparator($0, $1) }
        return MinMaxTerminalStage(previousStage: self, evaluator: evaluator!, comparator: invertedComparator).result
    }
}


public extension Stream where T : Hashable {
    func distinct() -> Stream<T> {
        return DistinctPipelineStage(previousStage: self)
    }
}

public extension Stream {
    static func +(left: Stream<T>, right: Stream<T>) -> Stream<T>
    {
        let spliterator = ConcatSpliterator(left: left.spliterator, right: right.spliterator)
        return PipelineHead(source: AnySpliterator(spliterator), characteristics: spliterator.options)
    }
}


public extension Stream where T : Summable {
    func sum() -> T {
        return self.reduce(identity: T(), accumulator: +)
    }
}

public extension Stream where T : StreamProtocol {
    func flatten() -> Stream<T.T> {
        return FlattenPipelineStage(previousStage: self)
    }
}


