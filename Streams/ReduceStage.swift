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
    private var sourceStage: AnyConsumer<SourceElement>
    
    
    private var identity: T
    private var accumulator: (T, T) -> T
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnyConsumer<SourceElement>, identity: T, accumulator: @escaping (T, T) -> T)
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
    
    func evaluate() -> T {
        while let element = source.advance() {
            sourceStage.consume(element)
        }
        return identity
    }
}
