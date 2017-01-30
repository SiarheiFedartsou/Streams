//
//  ReduceTerminalOperation.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

final class ReduceSink<T> : SinkProtocol {
    
    private var identity: T
    private let accumulator: (T, T) -> T
    
    init(identity: T, accumulator: @escaping (T, T) -> T) {
        self.identity = identity
        self.accumulator = accumulator
    }
    
    func begin(size: Int) {
        
    }
    
    func end() {
        
    }
    
    var cancellationRequested: Bool {
        return false
    }
    
    func consume(_ element: T) {
        identity = accumulator(identity, element)
    }
    
    var result: T {
        return identity
    }
}

final class ReduceTask<T> {
    
    let operation: ReduceTerminalOperation<T>
    let stage: UntypedPipelineStageProtocol
    var spliterator: AnySpliterator<Any>
    
    init(operation: ReduceTerminalOperation<T>, stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) {
        self.operation = operation
        self.stage = stage
        self.spliterator = spliterator
    }
    
    func invoke() -> T {
        if let splitted = spliterator.split() {
            var result1: T? = nil
            var result2: T? = nil

            DispatchQueue.concurrentPerform(iterations: 2, execute: { iteration in
                if iteration == 0 {
                    result1 = ReduceTask<T>(operation: self.operation, stage: self.stage, spliterator: splitted).invoke()
                } else {
                    result2 = ReduceTask<T>(operation: self.operation, stage: self.stage, spliterator: spliterator).invoke()
                }
            })
            
            return operation.accumulator(result1!, result2!)
        } else {
            let reduceSink = operation.makeSink()
            let sink = stage.wrap(sink: UntypedSink(reduceSink))
            spliterator.forEachRemaining { element in
                sink.consume(element)
            }
            return reduceSink.result
        }
    }
}

final class ReduceTerminalOperation<T> : TerminalOperationProtocol {
    
    let identity: T
    let accumulator: (T, T) -> T
    
    init(identity: T, accumulator: @escaping (T, T) -> T) {
        self.identity = identity
        self.accumulator = accumulator
    }
    
    func evaluateParallel(forPipelineStage stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> T {
        return ReduceTask(operation: self, stage: stage, spliterator: spliterator).invoke()
    }
    
    func evaluateSequential(forPipelineStage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> T {
        var spliterator = spliterator
        let reduceSink = makeSink()
        let sink = forPipelineStage.wrap(sink: UntypedSink(reduceSink))
        spliterator.forEachRemaining {
            sink.consume($0)
        }
        return reduceSink.result
    }
    
    fileprivate func makeSink() -> ReduceSink<T> {
        return ReduceSink(identity: identity, accumulator: accumulator)
    }
}
