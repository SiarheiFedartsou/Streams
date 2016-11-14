//
//  LimitStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class LimitPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement>
{
    var size: Int
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, size: Int)
    {
        self.size = size
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func consume(_ t: T) {
        if size > 0 {
            if let nextStage = self.nextStage {
                size -= 1
                nextStage.consume(t)
            }
        }
    }
}
