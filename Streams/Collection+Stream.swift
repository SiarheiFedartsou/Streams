//
//  Collection+Stream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

extension Collection {
    var stream: AnyStream<Self.Iterator.Element> {
        
        return AnyStream(PipelineHead<Self.Iterator.Element>(source: self.spliterator))
    }
    
    var spliterator: AnySpliterator<Self.Iterator.Element> {
        return AnySpliterator(IteratorSpliterator(iterator: self.makeIterator(), count: self.count, options: StreamOptions()))
    }
}
