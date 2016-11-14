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
    init(sourceStage: AnySink<SourceElement>, source: AnySpliterator<SourceElement>, size: Int)
    {
        self.sizeToSkip = size
        super.init(sourceStage: sourceStage, source: source)
    }
    
    
    override func begin(size: Int) {
        nextStage?.begin(size: 0)
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
    
    override func end() {
        nextStage?.end()
    }
    
    override var cancellationRequested: Bool {
        return self.nextStage?.cancellationRequested ?? false
    }
}
