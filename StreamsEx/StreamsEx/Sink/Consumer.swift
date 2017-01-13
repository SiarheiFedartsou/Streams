//
//  Consumer.swift
//  Streams
//
//  Created by Sergey Fedortsov on 13.11.16.
//  Copyright © 2016 Sergey Fedortsov. All rights reserved.
//

import Foundation

protocol ConsumerProtocol {
    associatedtype Consumable
    func consume(_ t: Consumable)
}


struct AnyConsumer<T> : ConsumerProtocol {
    
    private let _consume: (T) -> ()
    init<Consumer: ConsumerProtocol>(_ consumer: Consumer) where Consumer.Consumable == T
    {
        _consume = consumer.consume
    }
    
    func consume(_ t: T) {
        _consume(t)
    }
}
