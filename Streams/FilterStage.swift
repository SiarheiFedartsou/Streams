//
//  FilterStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class FilterPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement>
{
    let predicate: (T) -> Bool
    
    init(sourceStage: AnySink<SourceElement>, source: AnySpliterator<SourceElement>, predicate: @escaping (T) -> Bool)
    {
        self.predicate = predicate
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func begin(size: Int) {
        nextStage?.begin(size: 0)
    }
    
    override func consume(_ t: T) {
        if let nextStage = self.nextStage {
            if predicate(t) {
                nextStage.consume(t)
            }
        }
    }
    
    override func end() {
        nextStage?.end()
    }
}
