//
//  Collection+Stream.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

public protocol SplitableCollection : Collection  {
    var spliterator: AnySpliterator<Self.Iterator.Element> { get }
}


public extension Collection where Self : SplitableCollection {
    var stream: Stream<Self.Iterator.Element> {
        
        return PipelineHead<Self.Iterator.Element>(source: self.spliterator, characteristics: [.ordered, .sized], parallel: false)
    }
    
    var parallelStream: Stream<Self.Iterator.Element> {
        
        return PipelineHead<Self.Iterator.Element>(source: self.spliterator, characteristics: [.ordered, .sized], parallel: true)
    }
}

extension Array : SplitableCollection {
    public var spliterator: AnySpliterator<Element> {
        let spliterator = ArraySpliterator<Element>(array: self)
        return AnySpliterator(spliterator)
    }
}

