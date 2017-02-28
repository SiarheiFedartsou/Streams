//
//  ReduceTerminalOperation.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 13.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

final class ReduceSink<U, T> : SinkProtocol {
    
    private var identity: U
    private let accumulator: (U, T) -> U
    
    init(identity: U, accumulator: @escaping (U, T) -> U) {
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
    
    var result: U {
        return identity
    }
}

final class ReduceTask<U, T> {
    
    let operation: ReduceTerminalOperation<U, T>
    let stage: UntypedPipelineStageProtocol
    var spliterator: AnySpliterator<Any>
    
    init(operation: ReduceTerminalOperation<U, T>, stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) {
        self.operation = operation
        self.stage = stage
        self.spliterator = spliterator
    }
    
    func invoke() -> U {
        if let splitted = spliterator.split() {
            var result1: U? = nil
            var result2: U? = nil

            DispatchQueue.concurrentPerform(iterations: 2, execute: { iteration in
                if iteration == 0 {
                    result1 = ReduceTask<U, T>(operation: self.operation, stage: self.stage, spliterator: splitted).invoke()
                } else {
                    result2 = ReduceTask<U, T>(operation: self.operation, stage: self.stage, spliterator: spliterator).invoke()
                }
            })
            
            return operation.combiner(result1!, result2!)
        } else {
            let reduceSink = operation.makeSink()
            let sink = stage.unsafeWrap(sink: UntypedSink(reduceSink))
            spliterator.forEachRemaining { element in
                sink.consume(element)
            }
            return reduceSink.result
        }
    }
}

final class ReduceTerminalOperation<U, T> : TerminalOperationProtocol {
    
    let identity: U
    let accumulator: (U, T) -> U
    let combiner: (U, U) -> U
    
    init(identity: U, accumulator: @escaping (U, T) -> U, combiner: @escaping (U, U) -> U) {
        self.identity = identity
        self.accumulator = accumulator
        self.combiner = combiner
    }
    
    func evaluateParallel(forPipelineStage stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> U {
        return ReduceTask(operation: self, stage: stage, spliterator: spliterator).invoke()
    }
    
    func evaluateSequential(forPipelineStage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> U {
        var spliterator = spliterator
        let reduceSink = makeSink()
        let sink = forPipelineStage.unsafeWrap(sink: UntypedSink(reduceSink))
        spliterator.forEachRemaining {
            sink.consume($0)
        }
        return reduceSink.result
    }
    
    fileprivate func makeSink() -> ReduceSink<U, T> {
        return ReduceSink(identity: identity, accumulator: accumulator)
    }
}
