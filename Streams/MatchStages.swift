//
//  MatchStages.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class NoneMatchTerminalStage<T, SourceElement> : TerminalStage {
    private let predicate: (T) -> (Bool)
    private var source: AnySpliterator<SourceElement>
    private var sourceStage: AnyConsumer<SourceElement>
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnyConsumer<SourceElement>, predicate: @escaping (T) -> Bool)
    {
        self.source = source
        self.sourceStage = sourceStage
        self.predicate = predicate
    }
    
    private var noneMatch: Bool = false
    
    func consume(_ t: T) {
        if !predicate(t) {
            noneMatch = true
        }
    }
    
    func evaluate() -> Bool {
        while let element = source.advance() {
            sourceStage.consume(element)
        }
        return noneMatch
    }
}
