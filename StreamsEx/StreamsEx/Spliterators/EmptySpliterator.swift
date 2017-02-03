//
//  EmptySpliterator.swift
//  Streams
//
//  Created by Sergey Fedortsov on 28.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct EmptySpliterator<T> : SpliteratorProtocol {
    
    mutating func advance() -> T? {
        return nil
    }
    
    mutating func forEachRemaining(_ each: (T) -> Void) {
    }
    
    mutating func split() -> AnySpliterator<T>? {
        return nil
    }
    
    var estimatedSize: IntMax {
        return 0
    }
    
    var characteristics: SpliteratorCharacteristics {
        return [.sized, .subsized]
    }
}
