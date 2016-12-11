//
//  UntypedSink.swift
//  Streams
//
//  Created by Sergey Fedortsov on 11.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

protocol UntypedSinkProtocol {
    func begin(size: Int)
    func end()
    var cancellationRequested: Bool { get }
    func finalResult() -> Any?
    func consume(_ element: Any)
}

struct UntypedSink<Sink: SinkProtocol> : UntypedSinkProtocol {
    
    private let sink: Sink
    
    init(_ sink: Sink) {
        self.sink = sink
    }
    
    func begin(size: Int) {
        self.sink.begin(size: size)
    }
    
    func end() {
        self.sink.end()
    }
    
    var cancellationRequested: Bool {
        return self.sink.cancellationRequested
    }
    
    func finalResult() -> Any? {
        return self.sink.finalResult()
    }
    
    func consume(_ element: Any) {
        self.sink.consume(element as! Sink.Consumable)
    }
    
}
