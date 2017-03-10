//
//  DistinctPipelineStage.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 27.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

final class DistinctPipelineStageSink<T: Hashable> : SinkProtocol {
   
    private var seen: Set<T> = Set<T>()
    
    private let nextSink: UntypedSinkProtocol
    
    init(nextSink: UntypedSinkProtocol) {
        self.nextSink = nextSink
    }
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func consume(_ element: T) {
        if !seen.contains(element) {
            seen.insert(element)
            nextSink.consume(element)
        }
    }
    
    func end() {
        nextSink.end()
    }
    
    var cancellationRequested: Bool {
        return nextSink.cancellationRequested
    }
}


final class DistinctPipelineStage<T: Hashable, SourceSpliterator: SpliteratorProtocol, PreviousStage: PipelineStageProtocol> : PipelineStage<T, T, SourceSpliterator, PreviousStage> where PreviousStage.PipelineStageOut == T
{
    
    override func unsafeMakeSink(withNextSink nextSink: UntypedSinkProtocol) -> UntypedSinkProtocol {
        return UntypedSink(DistinctPipelineStageSink<T>(nextSink: nextSink))
    }
    
    override var isStateful: Bool {
        return true
    }
    
    override func unsafeEvaluateParallelLazy(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> AnySpliterator<Any> {
        if stage.combinedFlags.contains(.distinct) {
            return stage.unsafeWrap(spliterator: spliterator)
        } else if stage.combinedFlags.contains(.ordered) {
            let reduceOperation = ReduceTerminalOperation<OrderedSet<T>, T>(identity: OrderedSet<T>(), accumulator: { (set, element) in
                var result = set
                result.append(element)
                return result
            }, combiner: { (setA, setB)  in
                var result = setA
                result.append(contentsOf: setB)
                return result
            })
            
            let distinctArray = stage.evaluate(terminalOperation: reduceOperation).array
            let castingSpliterator = CastingSpliterator<T, Any>(spliterator: distinctArray.spliterator)
            return AnySpliterator(castingSpliterator)
        } else {
            let spliterator = CastingSpliterator<Any, T>(spliterator: stage.unsafeWrap(spliterator: spliterator))
            let distinctSpliterator = DistinctSpliterator(spliterator: spliterator)
            let castingSpliterator = CastingSpliterator<T, Any>(spliterator: AnySpliterator(distinctSpliterator))
            return AnySpliterator(castingSpliterator)
        }
        
    }
    
    override func evaluateParallel(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>) -> UntypedNodeProtocol {
       _abstract()
        //
    }
}
