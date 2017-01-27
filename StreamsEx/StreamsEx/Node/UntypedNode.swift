//
//  UntypedNode.swift
//  StreamsEx
//
//  Created by Siarhei Fedartsou on 27.01.17.
//  Copyright © 2017 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol UntypedNodeProtocol {
    
    var spliterator: UntypedSpliteratorProtocol { get }
    
    func forEach(_ each: (Any) -> ())
    
    var childCount: IntMax { get }
    func child(at index: IntMax) throws -> UntypedNodeProtocol
    
    func array() -> [Any]
    var count: IntMax { get }
}


struct UntypedNode<Node: NodeProtocol> : UntypedNodeProtocol {
    private var node: Node
    
    init(_ node: Node) {
        self.node = node
    }
    
    var spliterator: UntypedSpliteratorProtocol {
        return UntypedSpliterator(node.spliterator)
    }
    

    func forEach(_ each: (Any) -> ()) {
        node.forEach(each)
    }
    
    var childCount: IntMax {
        return node.childCount
    }
    
    func child(at index: IntMax) throws -> UntypedNodeProtocol {
        return try UntypedNode(node.child(at: index) as! Node)
    }
    
    func array() -> [Any] {
        return node.array()
    }
    
    var count: IntMax {
        return node.count
    }
}
