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
    
    func finalResult() -> Any?
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
 
    func finalResult() -> Any? {
        return box.finalResult()
    }
    
}

class AnySinkBoxBase<T>: SinkProtocol {
    func begin(size: Int) {}
    func end() {}
    
    var cancellationRequested: Bool { return false }
    
    func consume(_ t: T) {}
    
    func finalResult() -> Any? {
        _abstract()
    }
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
    
    override func finalResult() -> Any? {
        return self.base.finalResult()
    }
    
}

struct ChainedSink<T> : SinkProtocol {
    let nextSink: AnySink<T>
    
    func begin(size: Int) {
        nextSink.begin(size: size)
    }
    
    func end() {
        nextSink.end()
    }
    
    var cancellationRequested: Bool {
        return nextSink.cancellationRequested
    }
    
    func consume(_ t: T) {
        nextSink.consume(t)
    }
    
    func finalResult() -> Any? {
        return nextSink.finalResult()
    }
}
