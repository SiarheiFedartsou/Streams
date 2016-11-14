//
//  SkipStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


class SkipPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement>
{
    let sizeToSkip: Int
    var skipped: Int = 0
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, size: Int)
    {
        self.sizeToSkip = size
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func consume(_ t: T) {
        if (skipped == sizeToSkip) {
            if let nextStage = self.nextStage {
                nextStage.consume(t)
            }
        } else {
            skipped += 1
        }
    }
}
