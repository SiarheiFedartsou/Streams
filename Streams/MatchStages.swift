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
    private var sourceStage: AnySink<SourceElement>
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnySink<SourceElement>, predicate: @escaping (T) -> Bool)
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
    
    var result: Bool {
        return noneMatch
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
