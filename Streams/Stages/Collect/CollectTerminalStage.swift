//
//  CollectTerminalStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 04.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//


final class CollectTerminalStage<T, Accumulator, Result> : TerminalStage, SinkProtocol {
    private let collector: AnyCollector<T, Accumulator, Result>
    private var evaluator: EvaluatorProtocol
    
    init<PreviousStageType: PipelineStageProtocol>(previousStage: PreviousStageType,
         evaluator: EvaluatorProtocol, collector: AnyCollector<T, Accumulator, Result>) where PreviousStageType.Output == T
    {
        self.evaluator = evaluator
        self.collector = collector
        
        previousStage.nextStage = AnySinkFactory(self)
    }
    
    func makeSink() -> AnySink<T> {
        return AnySink(self)
    }
    
    var accumulator: Accumulator?
    var resultingContainer: Result?
    
    func begin(size: Int) {
        accumulator = collector.containerSupplier()
    }
    
    func consume(_ element: T) {
        guard let accumulator = accumulator else { return }
        self.accumulator = collector.accumulator(accumulator, element)
    }
    
    func end() {
        guard let accumulator = accumulator else { return }
        resultingContainer = collector.finisher(accumulator)
    }
    
    var cancellationRequested: Bool {
        return false
    }
    
    var result: Result {
        self.evaluator.evaluate()
        return resultingContainer!
    }
}
