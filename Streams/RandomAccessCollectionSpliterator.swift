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
    
    private(set) var options: StreamOptions
    
    private var index: Int = 0
    
    init(collection: AnyRandomAccessCollection<T>, options: StreamOptions)
    {
        self.collection = collection
        self.options = options
    }
    
    
    mutating func advance() -> T? {
        index += 1
        if IntMax(index) < collection.count {
            return self.collection[AnyIndex(index)]
        } else {
            return nil
        }
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void) {
        while let element = advance() {
            each(element)
        }
    }
    
    var estimatedSize: Int {
        return Int(self.collection.count)
    }
    
    mutating func split() -> AnySpliterator<T>? {
        //        let size = estimatedSize
        //
        /*
         Iterator<? extends T> i;
         long s;
         if ((i = it) == null) {
         i = it = collection.iterator();
         s = est = (long) collection.size();
         }
         else
         s = est;
         if (s > 1 && i.hasNext()) {
         int n = batch + BATCH_UNIT;
         if (n > s)
         n = (int) s;
         if (n > MAX_BATCH)
         n = MAX_BATCH;
         Object[] a = new Object[n];
         int j = 0;
         do { a[j] = i.next(); } while (++j < n && i.hasNext());
         batch = j;
         if (est != Long.MAX_VALUE)
         est -= j;
         return new ArraySpliterator<>(a, 0, j, characteristics);
         }
         return null;
         */
        
        return nil
    }
    
    
    
    private let batchUnit = 1 << 10
    private let maxBatch = 1 << 25
    
    
}
