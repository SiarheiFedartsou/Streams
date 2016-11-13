//
//  IteratorSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 09.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct IteratorSpliterator<T, Iterator: IteratorProtocol, Count: SignedInteger> : SpliteratorProtocol where Iterator.Element == T {
    private var iterator: Iterator
    private var options: StreamOptions
    private var count: Count
    
    init(iterator: Iterator, count: Count, options: StreamOptions)
    {
        self.iterator = iterator
        self.options = options
        self.count = count
    }
    
    mutating func advance() -> T? {
        return iterator.next()
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void) {
        while let element = iterator.next() {
            each(element)
        }
    }
    
    mutating func split() -> AnySpliterator<T>? {
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
