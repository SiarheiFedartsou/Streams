//
//  ForEachStage.swift
//  Streams
//
//  Created by Sergey Fedortsov on 14.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

class ForEachTerminalStage<T, SourceElement> : TerminalStage {
    
    private let each: (T) -> ()
    private var source: AnySpliterator<SourceElement>
    private var sourceStage: AnySink<SourceElement>
    
    init(source: AnySpliterator<SourceElement>, sourceStage: AnySink<SourceElement>, each: @escaping (T) -> ())
    {
        self.source = source
        self.sourceStage = sourceStage
        self.each = each
    }
    
    func consume(_ t: T) {
        each(t)
    }
    
    func evaluate() -> Void {
        sourceStage.begin(size: 0)
        while !sourceStage.cancellationRequested {
            guard let element = source.advance() else { break }
            sourceStage.consume(element)
        }
        sourceStage.end()
    }
}
