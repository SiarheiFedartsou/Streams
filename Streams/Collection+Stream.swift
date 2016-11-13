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
        
        return AnyStream(PipelineStage(source: self.spliterator))
        
     //   return AnyStream(Stream(spliterator: self.spliterator, parallel: false))
    }
    
    var spliterator: AnySpliterator<Self.Iterator.Element> {
        return AnySpliterator(IteratorSpliterator(iterator: self.makeIterator(), count: self.count, options: StreamOptions()))
    }
}
