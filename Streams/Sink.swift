//
//  Sink.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation


protocol SinkProtocol : ConsumerProtocol {
    func begin(size: Int)
    func end()
    
    var cancellationRequested: Bool { get }
}


extension SinkProtocol {
    func begin(size: Int) {}
    func end() {}
    var cancellationRequested: Bool {
        return false
    }
}

struct AnySink<T> : SinkProtocol {
    
    private let box: AnySinkBoxBase<T>

    init<Base: SinkProtocol>(_ base: Base) where Base.Consumable == T
    {
        box = AnySinkBox(base)
    }
    
    func begin(size: Int) {
        box.begin(size: size)
    }
    
    func end() {
        box.end()
    }
    
    var cancellationRequested: Bool {
        return box.cancellationRequested
    }
    
    func consume(_ t: T) {
        box.consume(t)
    }
    
}

class AnySinkBoxBase<T>: SinkProtocol {
    func begin(size: Int) {}
    func end() {}
    
    var cancellationRequested: Bool { return false }
    
    func consume(_ t: T) {}
}

final class AnySinkBox<Base: SinkProtocol>: AnySinkBoxBase<Base.Consumable> {
    private var base: Base
    
    init(_ base: Base)
    {
        self.base = base
    }
    
    override func begin(size: Int) {
        self.base.begin(size: size)
    }
    
    override func end() {
        self.base.end()
    }
    
    override var cancellationRequested: Bool {
        return self.base.cancellationRequested
    }
    
    override func consume(_ t: Base.Consumable)
    {
        self.base.consume(t)
    }
    
}

//struct ChainedSink<T, Out> : SinkProtocol {
//    
//}
