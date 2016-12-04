//
//  ToArrayCollector.swift
//  Streams
//
//  Created by Sergey Fedortsov on 04.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

struct ToArrayCollector<T> : Collector {
    let accumulator: ([T], T) -> [T] = {
            var array = $0
            array.append($1)
            return array
    }
    
    var combiner: ([T], [T]) -> [T] = {
            var array = $0
            array.append(contentsOf: $1)
            return array
    }
    
    var finisher: ([T]) -> [T] = { $0 }
    var containerSupplier: () -> [T] = { [T]() }
}

public func toArray<T>() -> AnyCollector<T, [T], [T]> {
    return AnyCollector(ToArrayCollector())
}
