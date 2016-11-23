//
//  ReduceStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


class ReduceTerminalStage<T, SourceElement> : TerminalStage {
    private var source: AnySpliterator<SourceElement>
    private var sourceStage: AnySink<SourceElement>
    
    
    private var identity: T
    private var accumulator: (T, T) -> T
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnySink<SourceElement>, identity: T, accumulator: @escaping (T, T) -> T)
    {
        self.source = source
        self.sourceStage = sourceStage
        self.identity = identity
        self.accumulator = accumulator
    }
    
    private var noneMatch: Bool = false
    
    func consume(_ t: T) {
        identity = accumulator(identity, t)
    }
    
    var result: T {
        return identity
    }
    
    func evaluate() {
        sourceStage.begin(size: 0)
        while !sourceStage.cancellationRequested {
            guard let element = source.advance() else { break }
            sourceStage.consume(element)
        }
        sourceStage.end()
    }
}
