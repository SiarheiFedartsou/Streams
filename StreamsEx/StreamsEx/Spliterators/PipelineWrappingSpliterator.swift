//
//  PipelineWrappingSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 27.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

fileprivate final class UnsafeBuffer : SinkProtocol {
    var storage: ContiguousArray<Any> = []
    
    func consume(_ element: Any) {
        storage.append(element)
    }
    
    subscript(index: Int) -> Any {
        return storage[index]
    }
    
    var count: Int {
        return storage.count
    }
    
    func clear() {
        storage.removeAll()
    }
}

/*
 
 
 */
final class UnsafeWrappingSpliterator : SpliteratorProtocol {
    
    let stage: UntypedPipelineStageProtocol
    var spliterator: AnySpliterator<Any>
    let isParallel: Bool
    
    private var buffer: UnsafeBuffer = UnsafeBuffer()
    private var nextToConsume: Int = 0
    
    private let bufferSink: UntypedSinkProtocol
    
    private var finished: Bool = false
    
    init(stage: UntypedPipelineStageProtocol, spliterator: AnySpliterator<Any>, isParallel: Bool) {
        self.stage = stage
        self.spliterator = spliterator
        self.isParallel = isParallel
        
        bufferSink = stage.unsafeWrap(sink: UntypedSink(buffer))
    }
    
    private func push() -> Bool {
        if let element = spliterator.advance() {
            bufferSink.consume(element)
            return true
        } else {
            return false
        }
    }
    
    private func doAdvance() -> Bool {
        if buffer.count == 0 {
            if finished {
                return false
            }
            nextToConsume = 0
            // TODO: exact size!
            bufferSink.begin(size: 0)
            return fillBuffer()
        } else {
            nextToConsume += 1
            var hasNext = nextToConsume < buffer.count
            if !hasNext {
                nextToConsume = 0
                buffer.clear()
                hasNext = fillBuffer()
            }
            return hasNext
        }
    }
    
    private func fillBuffer() -> Bool {
        while buffer.count == 0 {
            if bufferSink.cancellationRequested || !push() {
                if finished {
                    return false
                } else {
                    bufferSink.end()
                    finished = true
                }
            }
        }
        return true
    }
    
    func advance() -> Any? {
        let hasNext = doAdvance()
        
        return hasNext ? buffer[nextToConsume] : nil
    }
    
    func forEachRemaining(_ each: (Any) -> Void) {
        while let element = advance() {
            each(element)
        }
    }
    
    func split() -> AnySpliterator<Any>? {
        if isParallel && !finished {
            if let split = spliterator.split() {
                return AnySpliterator(UnsafeWrappingSpliterator(stage: stage, spliterator: split, isParallel: true))
            } else {
                return nil
            }
        }
        return nil
    }
    
    
    var estimatedSize: IntMax {
        return spliterator.estimatedSize
    }
    
    var exactSize: IntMax? {
        // TODO: !!!
        _abstract()
    }
    
    var characteristics: SpliteratorCharacteristics {
        // TODO: !!!
        _abstract()
    }
}

fileprivate final class Buffer<T> : SinkProtocol {
    var storage: ContiguousArray<T> = []
    
    func consume(_ element: T) {
        storage.append(element)
    }
    
    subscript(index: Int) -> T {
        return storage[index]
    }
    
    var count: Int {
        return storage.count
    }
    
    func clear() {
        storage.removeAll()
    }
}

/*
 
 
 */
final class WrappingSpliterator<Spliterator: SpliteratorProtocol, Stage: PipelineStageProtocol & UntypedPipelineStageProtocol> : SpliteratorProtocol {
    
    let stage: Stage
    var spliterator: Spliterator
    let isParallel: Bool
    
    private var buffer: Buffer<Stage.PipelineStageOut> = Buffer<Stage.PipelineStageOut>()
    private var nextToConsume: Int = 0
    
    private let bufferSink: UntypedSinkProtocol
    
    private var finished: Bool = false
    
    init(stage: Stage, spliterator: Spliterator, isParallel: Bool) {
        self.stage = stage
        self.spliterator = spliterator
        self.isParallel = isParallel
        
        bufferSink = stage.unsafeWrap(sink: UntypedSink(buffer))
    }
    
    private func push() -> Bool {
        if let element = spliterator.advance() {
            bufferSink.consume(element)
            return true
        } else {
            return false
        }
    }
    
    private func doAdvance() -> Bool {
        if buffer.count == 0 {
            if finished {
                return false
            }
            nextToConsume = 0
            // TODO: exact size!
            bufferSink.begin(size: 0)
            return fillBuffer()
        } else {
            nextToConsume += 1
            var hasNext = nextToConsume < buffer.count
            if !hasNext {
                nextToConsume = 0
                buffer.clear()
                hasNext = fillBuffer()
            }
            return hasNext
        }
    }
    
    private func fillBuffer() -> Bool {
        while buffer.count == 0 {
            if bufferSink.cancellationRequested || !push() {
                if finished {
                    return false
                } else {
                    bufferSink.end()
                    finished = true
                }
            }
        }
        return true
    }
    
    func advance() -> Stage.PipelineStageOut? {
        let hasNext = doAdvance()
        
        return hasNext ? buffer[nextToConsume] : nil
    }
    
    func forEachRemaining(_ each: (Stage.PipelineStageOut) -> Void) {
        while let element = advance() {
            each(element)
        }
    }
    
    func split() -> AnySpliterator<Stage.PipelineStageOut>? {
        if isParallel && !finished {
            if let split = spliterator.split() {
                let wrappingSpliterator = WrappingSpliterator<AnySpliterator<Spliterator.Element>, Stage>(stage: stage, spliterator: split, isParallel: true)
                return AnySpliterator(wrappingSpliterator)
            } else {
                return nil
            }
        }
        return nil
    }
    
    
    var estimatedSize: IntMax {
        return spliterator.estimatedSize
    }
    
    var exactSize: IntMax? {
        // TODO: !!!
        _abstract()
    }
    
    var characteristics: SpliteratorCharacteristics {
        // TODO: !!!
        _abstract()
    }
}




