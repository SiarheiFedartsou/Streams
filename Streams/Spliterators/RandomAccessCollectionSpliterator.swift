//
//  RandomAccessCollectionSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 16.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct RandomAccessCollectionSpliterator<T> : SpliteratorProtocol  {
    
    private var collection: AnyRandomAccessCollection<T>
    private var index: AnyIndex
    private var fence: AnyIndex
    private(set) var options: StreamOptions
    
    
    init(collection: AnyRandomAccessCollection<T>, options: StreamOptions)
    {
        self.init(collection: collection, origin: collection.startIndex, fence: collection.endIndex, options: options)
    }
    
    
    
    init(collection: AnyRandomAccessCollection<T>, origin: AnyIndex, fence: AnyIndex, options: StreamOptions)
    {
        self.collection = collection
        self.options = options
        self.index = origin
        self.fence = fence
    }
    
    
    mutating func advance() -> T? {
        if (index < fence) {
        
            let element = collection[index]
        
            collection.formIndex(after: &self.index)
            return element
        }
        return nil
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void) {
        while let element = advance() {
            each(element)
        }
    }
    
    var estimatedSize: Int {
        return Int(collection.distance(from: index, to: fence))
    }
    
    mutating func split() -> AnySpliterator<T>? {
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
