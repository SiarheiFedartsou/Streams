//
//  Node.swift
//  StreamsEx
//
//  Created by Sergey Fedortsov on 27.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

enum NodeError : Error {
    case indexOutOfBounds
}

protocol Node {
    associatedtype Element
    
    var spliterator: AnySpliterator<Element> { get }
    
    func forEach(_ each: (Element) -> ())
    
    var childCount: IntMax { get }
    func child(at index: IntMax) throws -> Self
    
    func array() -> [Element]
    var count: IntMax { get }
}

extension Node {
    var childCount: IntMax {
        return 0
    }
    
    func child(at index: IntMax) throws -> Self {
        throw NodeError.indexOutOfBounds
    }
}
