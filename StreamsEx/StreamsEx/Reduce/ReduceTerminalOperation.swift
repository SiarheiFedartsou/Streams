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

final class ReduceTerminalOperation<T> : TerminalOperationProtocol {
    
    let identity: T
    let accumulator: (T, T) -> T
    
    init(identity: T, accumulator: @escaping (T, T) -> T) {
        self.identity = identity
        self.accumulator = accumulator
    }
    
    func evaluateParallel(forPipelineStage: UntypedPipelineStageProtocol, spliterator: UntypedSpliteratorProtocol) -> T {
        _abstract()
    }
    
    func evaluateSequential(forPipelineStage: UntypedPipelineStageProtocol, spliterator: UntypedSpliteratorProtocol) -> T {
        var spliterator = spliterator
        let reduceSink = makeSink()
        let sink = forPipelineStage.wrap(sink: UntypedSink(reduceSink))
        spliterator.forEachRemaining {
            sink.consume($0)
        }
        return reduceSink.result
    }
    
    private func makeSink() -> ReduceSink<T> {
        return ReduceSink(identity: identity, accumulator: accumulator)
    }
}
