//
//  ConcatSpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 27.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


struct ConcatSpliterator<T> : SpliteratorProtocol {
    
    var left: AnySpliterator<T>
    var right: AnySpliterator<T>
    
    var beforeSplit: Bool = true
    
    init(left: AnySpliterator<T>, right: AnySpliterator<T>) {
        self.left = left
        self.right = right
    }
    
    mutating func advance() -> T? {
        if beforeSplit {
            if let next = left.advance() {
                return next
            } else {
                beforeSplit = false
                return right.advance()
            }
        } else {
            return right.advance()
        }
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void) {
        if beforeSplit {
            left.forEachRemaining(each)
        }
        right.forEachRemaining(each)
    }
    
    mutating func split() -> AnySpliterator<T>? {
        let result = beforeSplit ? left : right.split()
        beforeSplit = false
        return result
    }
    
    var options: StreamOptions {
        if beforeSplit {
            var characteristics = left.options.union(right.options)
            characteristics.remove(.ordered)
            characteristics.remove(.sized)
            return characteristics
        } else {
            return right.options
        }
    }
    
    var estimatedSize: Int {
        if beforeSplit {
            let size = left.estimatedSize + right.estimatedSize
            return size >= 0 ? size : Int.max
        } else {
            return right.estimatedSize
        }
    }
}
