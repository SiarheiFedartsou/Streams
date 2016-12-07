//
//  RandomAccessCollectionSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 16.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct RandomAccessCollectionSpliterator<Elements: Collection> : SpliteratorProtocol  {
    
    private var collection: Elements
    private var index: Elements.Index
    private var fence: Elements.Index
    private(set) var options: StreamOptions
    
    
    init(collection: Elements, options: StreamOptions)
    {
        self.init(collection: collection, origin: collection.startIndex, fence: collection.endIndex, options: options)
    }
    
    
    
    init(collection: Elements, origin: Elements.Index, fence: Elements.Index, options: StreamOptions)
    {
        self.collection = collection
        self.options = options
        self.index = origin
        self.fence = fence
    }
    
    
    mutating func advance() -> Elements.Iterator.Element? {
        if index == fence { return nil }
        
        let element = collection[index]
        collection.formIndex(after: &index)
        return element
    }
    
    mutating func forEachRemaining(_ each: (Elements.Iterator.Element) -> Void) {
        while let element = advance() {
            each(element)
        }
    }
    
    var estimatedSize: Int {
        // TODO: !!!
        return Int(collection.distance(from: index, to: fence) as! Int64)
    }
    
    mutating func split() -> AnySpliterator<Elements.Iterator.Element>? {
        guard estimatedSize > 512 else { return nil }
        let lo = index
        let mid = collection.index(lo, offsetBy: collection.distance(from: lo, to: fence) / 2)
        guard lo < mid else { return nil }
        
        index = mid
        
        return AnySpliterator(RandomAccessCollectionSpliterator(collection: collection,
                                                                origin: lo,
                                                                fence: mid,
                                                                options: options))
    }
}
