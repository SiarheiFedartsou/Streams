//
//  Generators.swift
//  Streams
//
//  Created by Sergey Fedortsov on 29.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

struct GenerateIterator<T> : IteratorProtocol {
    
    let generator: () -> T?
    
    func next() -> T? {
        return self.generator()
    }
}


public func generate<T>(_ generator: @escaping () -> T?) -> Stream<T>
{
    let iterator = GenerateIterator<T>(generator: generator)
    let spliterator = AnySpliterator(IteratorSpliterator(iterator: iterator, count: -1, options: StreamOptions()))
    return PipelineHead(source: spliterator, characteristics: .ordered)
}

struct IterateIterator<T> : IteratorProtocol {
    
    let producer: (T) -> T?
    let seed: T
    
    var previousValue: T? = nil
    
    init(seed: T, producer: @escaping (T) -> T?) {
        self.seed = seed
        self.producer = producer
    }
    
    mutating func next() -> T? {
        guard let previousValue = previousValue else {
            self.previousValue = seed
            return self.previousValue
        }
        self.previousValue = producer(previousValue)
        return self.previousValue
    }
}

public func iterate<T>(seed: T, producer: @escaping (T) -> T?) -> Stream<T>
{
    let iterator = IterateIterator<T>(seed: seed, producer: producer)
    let spliterator = AnySpliterator(IteratorSpliterator(iterator: iterator, count: -1, options: StreamOptions()))
    return PipelineHead(source: spliterator, characteristics: .ordered)
}
