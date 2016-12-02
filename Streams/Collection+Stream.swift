//
//  Collection+Stream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

public extension Collection {
    var stream: Stream<Self.Iterator.Element> {
        
        return PipelineHead<Self.Iterator.Element>(source: self.spliterator, characteristics: [.ordered, .sized], parallel: false)
    }
    
    var parallelStream: Stream<Self.Iterator.Element> {
        
        return PipelineHead<Self.Iterator.Element>(source: self.spliterator, characteristics: [.ordered, .sized], parallel: true)
    }
    
    
    internal var spliterator: AnySpliterator<Self.Iterator.Element> {
        return AnySpliterator(IteratorSpliterator(iterator: self.makeIterator(), count: self.count, options: StreamOptions()))
    }
}
