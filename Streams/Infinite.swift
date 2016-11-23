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


public func iterate<T>(_ generator: @escaping () -> T) -> Stream<T>
{
    let iterator = InfiniteIterator<T>(generator: generator)
    let spliterator = AnySpliterator(IteratorSpliterator(iterator: iterator, count: -1, options: StreamOptions()))
    return PipelineHead(source: spliterator)
}
