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
        
        return PipelineHead<Self.Iterator.Element, AnySpliterator<Self.Iterator.Element>>(source: spliterator, flags: StreamFlagsModifiers(characteristics: spliterator.characteristics), parallel: false)
    }
    
    var parallelStream: Stream<Self.Iterator.Element> {
        
        return PipelineHead<Self.Iterator.Element, AnySpliterator<Self.Iterator.Element>>(source: spliterator, flags: StreamFlagsModifiers(characteristics: spliterator.characteristics), parallel: true)
    }
}

extension Array : SplitableCollection {
    public var spliterator: AnySpliterator<Element> {
        let spliterator = ArraySpliterator<Element>(array: self)
        return AnySpliterator(spliterator)
    }
}

extension Set : SplitableCollection {
    public var spliterator: AnySpliterator<Element> {
        let spliterator = SetSpliterator<Element>(set: self)
        return AnySpliterator(spliterator)
    }
}

