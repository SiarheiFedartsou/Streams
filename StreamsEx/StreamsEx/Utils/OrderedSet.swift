//
//  OrderedSet.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 05.02.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import Foundation

// "silly" implementation of OrderedSet in Swift,
// just for first time
struct OrderedSet<T: Hashable> {
    private var storage: [T] = [T]()
    private var hasElements: Set<T> = Set<T>()
    
    mutating func append(_ element: T) {
        if !hasElements.contains(element) {
            storage.append(element)
            hasElements.insert(element)
        }
    }
    
    mutating func append(contentsOf set: OrderedSet<T>) {
        for element in set.storage {
            append(element)
        }
    }
    
    var array: [T] {
        return storage
    }
}
