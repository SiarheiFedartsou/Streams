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

protocol NodeProtocol {
    associatedtype Element
    
    var spliterator: AnySpliterator<Element> { get }
    
    func forEach(_ each: (Element) -> ())
    
    var childCount: IntMax { get }
    func child(at index: IntMax) throws -> AnyNode<Element>
    
    func array() -> [Element]
    var count: IntMax { get }
}

extension NodeProtocol {
    var childCount: IntMax {
        return 0
    }
    
    func child(at index: IntMax) throws -> AnyNode<Element> {
        throw NodeError.indexOutOfBounds
    }
}



struct AnyNode<T> : NodeProtocol {
    private let box: AnyNodeBoxBase<T>
    
    init<Node: NodeProtocol>(_ node: Node) where Node.Element == T
    {
        box = AnyNodeBox(node)
    }
    
    var spliterator: AnySpliterator<T> {
        return box.spliterator
    }
    
    func forEach(_ each: (T) -> ()) {
        box.forEach(each)
    }
    
    var childCount: IntMax {
        return box.childCount
    }
    
    func child(at index: IntMax) throws -> AnyNode<T> {
        return try box.child(at: index)
    }
    
    func array() -> [T] {
        return box.array()
    }
    
    var count: IntMax {
        return box.count
    }

}

class AnyNodeBoxBase<T>: NodeProtocol {
    var spliterator: AnySpliterator<T> {
        _abstract()
    }
    
    func forEach(_ each: (T) -> ()) {
        _abstract()
    }
    
    var childCount: IntMax {
        _abstract()
    }
    
    func child(at index: IntMax) throws -> AnyNode<T> {
        _abstract()
    }
    
    func array() -> [T] {
        _abstract()
    }
    
    var count: IntMax {
        _abstract()
    }
}

final class AnyNodeBox<Base: NodeProtocol>: AnyNodeBoxBase<Base.Element> {
    private var base: Base
    init(_ base: Base)  {
        self.base = base
    }
    
    override var spliterator: AnySpliterator<Base.Element> {
        return base.spliterator
    }
    
    override func forEach(_ each: (Base.Element) -> ()) {
        base.forEach(each)
    }
    
    override var childCount: IntMax {
        return base.childCount
    }
    
    override func child(at index: IntMax) throws -> AnyNode<Base.Element> {
        return try base.child(at: index)
    }
    
    override func array() -> [Base.Element] {
        return base.array()
    }
    
    override var count: IntMax {
        return base.count
    }
}
