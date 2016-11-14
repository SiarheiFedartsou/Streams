//
//  MapStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


class MapPipelineStage<In, Out, SourceElement> : PipelineStage<In, Out, SourceElement>
{
    let mapper: (In) -> Out
    
    init(sourceStage: AnyConsumer<SourceElement>, source: AnySpliterator<SourceElement>, mapper: @escaping (In) -> Out)
    {
        self.mapper = mapper
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func consume(_ t: In) {
        if let nextStage = self.nextStage {
            nextStage.consume(mapper(t))
        }
    }
}
