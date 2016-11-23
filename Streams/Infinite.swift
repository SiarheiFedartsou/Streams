//
//  Infinite.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct InfiniteIterator<T> : IteratorProtocol {
    
    let generator: () -> T
    
    func next() -> T? {
        return self.generator()
    }
}


func iterate<T>(_ generator: @escaping () -> T) -> AnyStream<T>
{
    let iterator = InfiniteIterator<T>(generator: generator)
    let spliterator = AnySpliterator(IteratorSpliterator(iterator: iterator, count: -1, options: StreamOptions()))
    return AnyStream(PipelineHead(source: spliterator))
}
