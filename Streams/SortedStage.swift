//
//  SortedStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 16.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class SortedPipelineStage<T, SourceElement> : PipelineStage<T, T, SourceElement> where T : Comparable
{
    
    private var accumulator: [T] = []
    
    init(sourceStage: AnySink<SourceElement>, source: AnySpliterator<SourceElement>)
    {
        super.init(sourceStage: sourceStage, source: source)
    }
    
    override func begin(size: Int) {
        accumulator.reserveCapacity(size)
    }
    
    override func consume(_ t: T) {
        accumulator.append(t)
    }
    
    override func end() {
        accumulator.sort()
        nextStage?.begin(size: accumulator.count)
        for element in accumulator {
            nextStage?.consume(element)
        }
        nextStage?.end()
    }
}
//
//extension StreamProtocol {
//    func sorted() -> {
//       // return SortedPipelineStage()
//    }
//}
