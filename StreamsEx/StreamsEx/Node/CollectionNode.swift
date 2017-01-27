//
//  CollectionNode.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 27.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

struct CollectionNode<T> : NodeProtocol {
    // TODO: must be AnyCollection in the future
    private let collection: AnyRandomAccessCollection<T>
    
    var spliterator: AnySpliterator<T> {
        return collection.spliterator
    }
    
    func forEach(_ each: (T) -> ()) {
        collection.forEach(each)
    }
    
    func array() -> [T] {
        var array = [T]()
        for element in collection {
            array.append(element)
        }
        return array
    }
    
    var count: IntMax {
        return collection.count
    }
}
