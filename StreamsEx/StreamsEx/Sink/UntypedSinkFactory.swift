//
//  UntypedSinkFactory.swift
//  Streams
//
//  Created by Sergey Fedortsov on 22.12.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol UntypedSinkFactoryProtocol {
    func makeSink() -> UntypedSinkProtocol
}

struct UntypedSinkFactory<SF: SinkFactory> : UntypedSinkFactoryProtocol {
    private let sinkFactory: SF
    
    init(_ sinkFactory: SF) {
        self.sinkFactory = sinkFactory
    }
    
    func makeSink() -> UntypedSinkProtocol {
        return UntypedSink(self.sinkFactory.makeSink())
    }
}
