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

struct AnySink<T> {
    
}

//struct ChainedSink<T, Out> : SinkProtocol {
//    
//}
